import 'package:flutter/foundation.dart';
import '../models/adoption_request_details.dart';
import '../models/adoption_request_model.dart';
import '../models/email_notification_model.dart';
import '../models/enums.dart';
import '../repositories/database_repository.dart';

/// State management for Adoption Requests, Applications, and Workflows
class AdoptionProvider extends ChangeNotifier {
  final DatabaseRepository repository;

  List<AdoptionRequestDetails> _adopterRequests = [];
  List<AdoptionRequestDetails> _ownerRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  AdoptionProvider({required this.repository});

  List<AdoptionRequestDetails> get adopterRequests => _adopterRequests;
  List<AdoptionRequestDetails> get ownerRequests => _ownerRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Metric counts for dashboards
  int get adopterPendingCount =>
      _adopterRequests.where((r) => r.request.status == AdoptionRequestStatus.pending).length;
  int get adopterApprovedCount =>
      _adopterRequests.where((r) => r.request.status == AdoptionRequestStatus.approved).length;
  int get adopterCompletedCount =>
      _adopterRequests.where((r) => r.request.status == AdoptionRequestStatus.completed).length;

  int get ownerPendingCount =>
      _ownerRequests.where((r) => r.request.status == AdoptionRequestStatus.pending).length;
  int get ownerApprovedCount =>
      _ownerRequests.where((r) => r.request.status == AdoptionRequestStatus.approved).length;
  int get ownerCompletedCount =>
      _ownerRequests.where((r) => r.request.status == AdoptionRequestStatus.completed).length;

  Future<void> fetchAdopterRequests(String adopterId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _adopterRequests = await repository.getAdoptionRequestDetailsForAdopter(adopterId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOwnerRequests(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ownerRequests = await repository.getAdoptionRequestDetailsForOwner(ownerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> hasActiveRequest(String adopterId, String petId) async {
    try {
      return await repository.hasActiveAdoptionRequest(adopterId, petId);
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitApplication(AdoptionRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.saveAdoptionRequest(request);
      await fetchAdopterRequests(request.adopterId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('StateError: ', '').replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveRequest(
    String requestId,
    String ownerId, {
    String? deliveryMethod,
    String? deliveryAddress,
    String? deliveryDate,
    String? deliveryInstructions,
    String? paymentMethod,
    double? paymentAmount,
    String? paymentInstructions,
    String? approvalMessage,
    String? emailSentTo,
    EmailNotificationModel? emailNotification,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.approveAdoptionRequest(
        requestId,
        deliveryMethod: deliveryMethod,
        deliveryAddress: deliveryAddress,
        deliveryDate: deliveryDate,
        deliveryInstructions: deliveryInstructions,
        paymentMethod: paymentMethod,
        paymentAmount: paymentAmount,
        paymentInstructions: paymentInstructions,
        approvalMessage: approvalMessage,
        emailSentTo: emailSentTo,
        emailNotification: emailNotification,
      );
      await fetchOwnerRequests(ownerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<EmailNotificationModel>> getEmailsForUser(String userId) async {
    return await repository.getEmailNotificationsForUser(userId);
  }

  Future<List<EmailNotificationModel>> getEmailsForRequest(String requestId) async {
    return await repository.getEmailNotificationsForRequest(requestId);
  }

  Future<void> markEmailAsRead(String emailId) async {
    await repository.markEmailAsRead(emailId);
  }

  Future<bool> rejectRequest(String requestId, String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.rejectAdoptionRequest(requestId);
      await fetchOwnerRequests(ownerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeRequest(String requestId, String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.completeAdoptionRequest(requestId);
      await fetchOwnerRequests(ownerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelRequest(String requestId, String adopterId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.cancelAdoptionRequest(requestId, adopterId);
      await fetchAdopterRequests(adopterId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
