import 'package:flutter/foundation.dart';
import '../models/resource.dart';
import '../models/resource_request.dart';
import '../models/worker.dart';
import '../mock/mock_resources.dart';
import '../mock/mock_workers.dart';

class ResourceService extends ChangeNotifier {
  static final ResourceService _instance = ResourceService._internal();
  factory ResourceService() => _instance;

  ResourceService._internal() {
    _resources = MockResources.getInitialResources();
    _workers = MockWorkers.getInitialWorkers();
    _initInitialRequests();
  }

  late List<Resource> _resources;
  late List<FarmWorker> _workers;
  final List<ResourceRequest> _myRequests = [];
  final List<ResourceRequest> _requestsReceived = [];

  ResourceCategory? _selectedCategory;
  ResourceCategory? get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Resource> get resources => List.unmodifiable(_resources);
  List<FarmWorker> get workers => List.unmodifiable(_workers);
  List<ResourceRequest> get myRequests => List.unmodifiable(_myRequests);
  List<ResourceRequest> get requestsReceived => List.unmodifiable(_requestsReceived);

  List<Resource> get savedResources => _resources.where((r) => r.isSaved).toList();

  List<Resource> get myListedResources =>
      _resources.where((r) => r.providerName.toLowerCase().contains('you')).toList();

  void _initInitialRequests() {
    final now = DateTime.now();

    // My Sent Requests
    _myRequests.addAll([
      ResourceRequest(
        id: 'req_01',
        resourceType: 'Equipment',
        title: '13HP Power Tiller for Bed Preparation',
        description: 'Need for 1.5 acres bed preparation before transplanting capsicum seedlings.',
        requiredDate: 'Tomorrow Morning',
        duration: '2 Days',
        location: 'Field 01, Sector 2',
        status: RequestStatus.pending,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ResourceRequest(
        id: 'req_02',
        resourceType: 'Worker',
        title: '2 Farm Hands for Tomato Staking',
        description: 'Manual bamboo staking and tying for young tomato crop rows.',
        requiredDate: 'Upcoming Saturday',
        duration: '1 Day',
        location: 'Field 01',
        status: RequestStatus.accepted,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ResourceRequest(
        id: 'req_03',
        resourceType: 'Irrigation',
        title: 'Backpack Battery Sprayer',
        description: 'For morning organic neem oil application across 2 sectors.',
        requiredDate: 'Yesterday',
        duration: '1 Day',
        location: 'Field 01',
        status: RequestStatus.completed,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
    ]);

    // Requests Received (as an equipment owner)
    _requestsReceived.addAll([
      ResourceRequest(
        id: 'req_rec_01',
        resourceType: 'Equipment',
        title: 'Mahindra 45HP Tractor Request',
        description: 'Need tractor for deep ploughing in 2 acres. Requested by Anu Joseph (Kattappana).',
        requiredDate: '28 September',
        duration: '1 Day',
        location: 'Kattappana Sector 3',
        status: RequestStatus.pending,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      ResourceRequest(
        id: 'req_rec_02',
        resourceType: 'Irrigation',
        title: 'Drip Lateral Rolls Sharing',
        description: 'Requesting 2 rolls of 16mm inline drip laterals. Requested by Manu Thomas.',
        requiredDate: '29 September',
        duration: '3 Days',
        location: 'Nedumkandam',
        status: RequestStatus.accepted,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  List<Resource> get filteredResources {
    return _resources.where((resource) {
      final matchesCategory = _selectedCategory == null || resource.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resource.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resource.providerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resource.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void setCategory(ResourceCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSaveResource(String resourceId) {
    final index = _resources.indexWhere((r) => r.id == resourceId);
    if (index != -1) {
      final res = _resources[index];
      _resources[index] = res.copyWith(isSaved: !res.isSaved);
      notifyListeners();
    }
  }

  void addResource(Resource resource) {
    _resources.insert(0, resource);
    notifyListeners();
  }

  void addRequest(ResourceRequest request) {
    _myRequests.insert(0, request);
    notifyListeners();
  }

  void acceptReceivedRequest(String requestId) {
    final index = _requestsReceived.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requestsReceived[index] = _requestsReceived[index].copyWith(status: RequestStatus.accepted);
      notifyListeners();
    }
  }

  void declineReceivedRequest(String requestId) {
    final index = _requestsReceived.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requestsReceived[index] = _requestsReceived[index].copyWith(status: RequestStatus.completed);
      notifyListeners();
    }
  }

  void updateRequestStatus(String requestId, RequestStatus status) {
    final index = _myRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _myRequests[index] = _myRequests[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void cycleRequestStatus(String requestId) {
    final index = _myRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final current = _myRequests[index].status;
      RequestStatus next;
      switch (current) {
        case RequestStatus.pending:
          next = RequestStatus.accepted;
          break;
        case RequestStatus.accepted:
          next = RequestStatus.completed;
          break;
        case RequestStatus.completed:
          next = RequestStatus.pending;
          break;
      }
      _myRequests[index] = _myRequests[index].copyWith(status: next);
      notifyListeners();
    }
  }

  Resource? getResourceById(String id) {
    try {
      return _resources.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
