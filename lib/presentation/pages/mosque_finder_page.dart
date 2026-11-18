import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/nearby_mosques.dart';
import '../blocs/location_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';

class MosqueFinderPage extends StatefulWidget {
  const MosqueFinderPage({super.key, this.service});

  /// Injectable for tests.
  final NearbyMosquesService? service;

  @override
  State<MosqueFinderPage> createState() => _MosqueFinderPageState();
}

enum _LoadState { waitingForLocation, loading, loaded, error }

class _MosqueFinderPageState extends State<MosqueFinderPage> {
  final TextEditingController _searchController = TextEditingController();
  late final NearbyMosquesService _service =
      widget.service ?? NearbyMosquesService();

  _LoadState _state = _LoadState.waitingForLocation;
  List<NearbyMosque> _mosques = [];
  double? _lat;
  double? _lng;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoad();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  (double, double)? _currentCoords() {
    final settings = context.read<SettingsBloc>().state;
    if (!settings.useAutoLocation) {
      return (settings.manualLatitude, settings.manualLongitude);
    }
    final loc = context.read<LocationBloc>().state;
    if (loc is LocationLoaded) return (loc.latitude, loc.longitude);
    return null;
  }

  void _maybeLoad({bool force = false}) {
    final coords = _currentCoords();
    if (coords == null) {
      final loc = context.read<LocationBloc>().state;
      setState(() {
        _state =
            loc is LocationError
                ? _LoadState.error
                : _LoadState.waitingForLocation;
      });
      return;
    }
    if (!force &&
        _lat == coords.$1 &&
        _lng == coords.$2 &&
        _state != _LoadState.waitingForLocation) {
      return;
    }
    _load(coords.$1, coords.$2);
  }

  Future<void> _load(double lat, double lng) async {
    final id = ++_requestId;
    setState(() {
      _lat = lat;
      _lng = lng;
      _state = _LoadState.loading;
    });
    try {
      final result = await _service.fetch(lat, lng);
      if (!mounted || id != _requestId) return;
      setState(() {
        _mosques = result;
        _state = _LoadState.loaded;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() => _state = _LoadState.error);
    }
  }

  void _retry() {
    final coords = _currentCoords();
    if (coords == null) {
      context.read<LocationBloc>().add(FetchLocation());
      setState(() => _state = _LoadState.waitingForLocation);
      return;
    }
    _load(coords.$1, coords.$2);
  }

  Future<void> _launch(Uri uri) async {
    final failText = context.l10n.could_not_open_maps;
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) {
      showAppSnackBar(context, failText, type: SnackType.error);
    }
  }

  void _openDirections(NearbyMosque m) {
    _launch(
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${m.latitude},${m.longitude}',
      ),
    );
  }

  void _openMapsSearch() {
    final coords = _currentCoords();
    final uri =
        coords == null
            ? Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=mosque',
            )
            : Uri.parse(
              'https://www.google.com/maps/search/mosque/@${coords.$1},${coords.$2},14z',
            );
    _launch(uri);
  }

  String _formatDistance(BuildContext context, double meters) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    NumberFormat fmt(String pattern) {
      try {
        return NumberFormat(pattern, locale);
      } catch (_) {
        return NumberFormat(pattern);
      }
    }

    if (meters < 1000) {
      return l10n.distance_m.replaceAll('{n}', fmt('0').format(meters));
    }
    return l10n.distance_km.replaceAll('{n}', fmt('0.0').format(meters / 1000));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _searchController.text.trim().toLowerCase();
    final visible =
        query.isEmpty
            ? _mosques
            : _mosques
                .where(
                  (m) =>
                      m.name.toLowerCase().contains(query) ||
                      (m.address?.toLowerCase().contains(query) ?? false),
                )
                .toList();

    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listener: (context, _) => _maybeLoad(),
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen:
              (p, c) =>
                  p.useAutoLocation != c.useAutoLocation ||
                  p.manualLatitude != c.manualLatitude ||
                  p.manualLongitude != c.manualLongitude,
          listener: (context, _) => _maybeLoad(),
        ),
      ],
      child: AppScaffold(
        title: l10n.mosque_finder,
        actions: [
          IconButton(
            tooltip: l10n.open_in_maps,
            icon: const Icon(Icons.map_outlined),
            onPressed: _openMapsSearch,
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: AppSpacing.only(start: 24, end: 24, top: 16, bottom: 12),
              child: AppSearchField(
                controller: _searchController,
                hint: l10n.search_mosques,
              ),
            ),
            Expanded(child: _buildBody(context, visible)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<NearbyMosque> visible) {
    final l10n = context.l10n;
    switch (_state) {
      case _LoadState.waitingForLocation:
        return StateView.loading(message: l10n.detecting_location);
      case _LoadState.loading:
        return SkeletonList(
          itemCount: 6,
          padding: AppSpacing.only(start: 24, end: 24, bottom: 24),
        );
      case _LoadState.error:
        final noLocation = _currentCoords() == null;
        return StateView.error(
          icon:
              noLocation
                  ? Icons.location_off_outlined
                  : Icons.cloud_off_rounded,
          message:
              noLocation
                  ? l10n.location_error_message
                  : l10n.mosques_load_error,
          onRetry: _retry,
          secondaryLabel: l10n.open_in_maps,
          onSecondary: _openMapsSearch,
        );
      case _LoadState.loaded:
        if (_mosques.isEmpty) {
          return StateView.empty(
            icon: Icons.mosque_outlined,
            message: l10n.no_mosques_nearby,
            actionLabel: l10n.open_in_maps,
            onAction: _openMapsSearch,
          );
        }
        if (visible.isEmpty) {
          return StateView.empty(
            icon: Icons.search_off_rounded,
            message: l10n.no_mosques_match,
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            final coords = _currentCoords();
            if (coords != null) await _load(coords.$1, coords.$2);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.only(start: 24, end: 24, bottom: 24),
            itemCount: visible.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vMd),
            itemBuilder: (context, index) {
              if (index == visible.length) {
                // ODbL attribution for the Overpass / OpenStreetMap data.
                return Padding(
                  padding: EdgeInsetsDirectional.only(top: AppSpacing.vSm),
                  child: Text(
                    l10n.osm_attribution,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return _buildMosqueTile(context, visible[index]);
            },
          ),
        );
    }
  }

  Widget _buildMosqueTile(BuildContext context, NearbyMosque m) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final name = m.name.isEmpty ? l10n.unnamed_mosque : m.name;
    final distance = _formatDistance(context, m.distanceMeters);
    return AppCard(
      onTap: () => _openDirections(m),
      padding: AppSpacing.tile,
      borderRadius: AppRadius.mdAll,
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.secondaryGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: AppColors.secondaryGold,
              size: 22.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (m.address != null) ...[
                  SizedBox(height: AppSpacing.vXs),
                  Text(
                    m.address!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.vXs),
                Text(
                  distance,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.secondaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.directions,
            icon: Icon(
              Icons.directions_rounded,
              color: AppColors.secondaryGold,
            ),
            onPressed: () => _openDirections(m),
          ),
        ],
      ),
    );
  }
}
