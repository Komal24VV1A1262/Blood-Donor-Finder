import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/blood_request.dart';
import '../providers/request_provider.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/urgency_badge.dart';
import 'add_request_screen.dart';
import 'donor_matches_screen.dart';

enum _RequestView { open, closed, all }

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  _RequestView _view = _RequestView.open;

  Future<void> _openAddRequest() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddRequestScreen()),
    );
    if (added == true && mounted) {
      setState(() => _view = _RequestView.open);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blood request posted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();

    if (provider.loading && provider.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.requests.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load requests',
        message: provider.error!,
        action: FilledButton(
          onPressed: provider.loadRequests,
          child: const Text('Retry'),
        ),
      );
    }

    final requests = switch (_view) {
      _RequestView.open => provider.openRequests,
      _RequestView.closed => provider.closedRequests,
      _RequestView.all => provider.requests,
    };

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                _ViewChip(
                  label: 'Open',
                  count: provider.openRequests.length,
                  selected: _view == _RequestView.open,
                  onTap: () => setState(() => _view = _RequestView.open),
                ),
                const SizedBox(width: 8),
                _ViewChip(
                  label: 'Closed',
                  count: provider.closedRequests.length,
                  selected: _view == _RequestView.closed,
                  onTap: () => setState(() => _view = _RequestView.closed),
                ),
                const SizedBox(width: 8),
                _ViewChip(
                  label: 'All',
                  count: provider.requests.length,
                  selected: _view == _RequestView.all,
                  onTap: () => setState(() => _view = _RequestView.all),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadRequests,
              child: requests.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.45,
                          child: EmptyState(
                            icon: Icons.water_drop_outlined,
                            title: _view == _RequestView.open
                                ? 'No open requests'
                                : 'Nothing here yet',
                            message: _view == _RequestView.open
                                ? 'Post a request when someone needs blood.'
                                : 'Requests you close will appear here.',
                            action: FilledButton.icon(
                              onPressed: _openAddRequest,
                              icon: const Icon(Icons.add),
                              label: const Text('Post request'),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _RequestCard(
                          request: request,
                          onFindDonors: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DonorMatchesScreen(request: request),
                              ),
                            );
                          },
                          onStatusChanged: (status) => _updateStatus(
                            request,
                            status,
                          ),
                          onDelete: () => _deleteRequest(request),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRequest,
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
    );
  }

  Future<void> _updateStatus(BloodRequest request, RequestStatus status) async {
    try {
      await context.read<RequestProvider>().setStatus(request.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked ${status.label.toLowerCase()}.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update request.')),
      );
    }
  }

  Future<void> _deleteRequest(BloodRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete request?'),
        content: Text('Remove the request for ${request.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<RequestProvider>().deleteRequest(request.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete request.')),
      );
    }
  }
}

class _ViewChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _ViewChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.bloodRed.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        color: selected ? AppTheme.darkRed : Colors.black87,
      ),
      side: BorderSide(
        color: selected
            ? AppTheme.bloodRed.withValues(alpha: 0.4)
            : Colors.grey.shade300,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BloodRequest request;
  final VoidCallback onFindDonors;
  final ValueChanged<RequestStatus> onStatusChanged;
  final VoidCallback onDelete;

  const _RequestCard({
    required this.request,
    required this.onFindDonors,
    required this.onStatusChanged,
    required this.onDelete,
  });

  Future<void> _call(BuildContext context) async {
    final phone = request.contactPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {
      // Fall through to the message below.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling is not supported on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupColor = AppTheme.bloodGroupColor(request.bloodGroup);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: groupColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    request.bloodGroup,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: groupColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          UrgencyBadge(urgency: request.urgency),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${request.city}'
                        '${request.hospital != null ? ' · ${request.hospital}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.units} '
                        '${request.units == 1 ? 'unit' : 'units'} needed · '
                        '${formatRelative(request.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More actions',
                  onSelected: (value) {
                    switch (value) {
                      case 'fulfilled':
                        onStatusChanged(RequestStatus.fulfilled);
                        break;
                      case 'cancelled':
                        onStatusChanged(RequestStatus.cancelled);
                        break;
                      case 'reopen':
                        onStatusChanged(RequestStatus.open);
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (request.isOpen) ...[
                      const PopupMenuItem(
                        value: 'fulfilled',
                        child: Text('Mark as fulfilled'),
                      ),
                      const PopupMenuItem(
                        value: 'cancelled',
                        child: Text('Cancel request'),
                      ),
                    ] else
                      const PopupMenuItem(
                        value: 'reopen',
                        child: Text('Reopen request'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  request.notes!,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _call(context),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: request.isOpen ? onFindDonors : null,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Find donors'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 13,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 3),
                Text(
                  'Requested by ${request.requesterName}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (!request.isOpen)
                  Text(
                    request.status.label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
