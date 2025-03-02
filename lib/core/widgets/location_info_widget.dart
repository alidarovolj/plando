import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';

/// Виджет для отображения информации о местоположении
class LocationInfoWidget extends ConsumerWidget {
  final VoidCallback? onLocationReceived;

  const LocationInfoWidget({
    Key? key,
    this.onLocationReceived,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationStatus(context, locationState),
        if (locationState.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (locationState.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              locationState.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (locationState.position != null)
          _buildLocationInfo(locationState.position!),
        const SizedBox(height: 16),
        _buildActionButtons(context, ref, locationState),
      ],
    );
  }

  Widget _buildLocationStatus(BuildContext context, LocationState state) {
    final theme = Theme.of(context);

    if (state.permissionGranted) {
      return Row(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Разрешение на доступ к местоположению получено',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            Icons.warning,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Требуется разрешение на доступ к местоположению',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildLocationInfo(Position position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Широта: ${position.latitude.toStringAsFixed(6)}'),
        const SizedBox(height: 4),
        Text('Долгота: ${position.longitude.toStringAsFixed(6)}'),
        const SizedBox(height: 4),
        Text('Точность: ${position.accuracy.toStringAsFixed(1)} м'),
        if (position.altitude != 0) ...[
          const SizedBox(height: 4),
          Text('Высота: ${position.altitude.toStringAsFixed(1)} м'),
        ],
        if (position.speed != 0) ...[
          const SizedBox(height: 4),
          Text('Скорость: ${position.speed.toStringAsFixed(1)} м/с'),
        ],
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, LocationState state) {
    final locationNotifier = ref.read(locationProvider.notifier);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await locationNotifier.getCurrentPosition();
            if (state.position != null && onLocationReceived != null) {
              onLocationReceived!();
            }
          },
          icon: const Icon(Icons.my_location),
          label: const Text('Получить местоположение'),
        ),
        if (!state.permissionGranted)
          OutlinedButton.icon(
            onPressed: () => locationNotifier.requestPermission(),
            icon: const Icon(Icons.perm_device_information),
            label: const Text('Запросить разрешение'),
          ),
        OutlinedButton.icon(
          onPressed: () => locationNotifier.openAppSettings(),
          icon: const Icon(Icons.settings),
          label: const Text('Настройки приложения'),
        ),
      ],
    );
  }
}
