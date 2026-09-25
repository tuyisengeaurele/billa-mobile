import 'package:dio/dio.dart';

String describeActionError(Object error) {
  // No response at all means the request never reached the server (offline,
  // timeout, dropped connection), which is the one failure the user can fix.
  if (error is DioException && error.response == null) {
    return 'Check your connection and try again';
  }
  // The server answers 429 with a plain body, not an error code, so the
  // status is the only reliable signal that the user is being rate limited.
  if (error is DioException && error.response?.statusCode == 429) {
    return 'Too many attempts. Wait a few minutes and try again';
  }
  // Proxies and gateways answer with HTML or plain text, not a JSON body.
  final data = error is DioException ? error.response?.data : null;
  final code = data is Map ? data['error'] as String? : null;
  return switch (code) {
    'no_lines' => 'Add at least one line before finalizing',
    'finalize_requires_approval' => 'Only the business owner can finalize documents',
    'already_finalized' => 'This document was already finalized',
    'not_convertible' => "This document type can't be converted to an invoice",
    'not_finalized' => 'Finalize this document first',
    'already_converted' => 'This was already converted to an invoice',
    'already_declined' => 'The customer already declined this',
    'customer_has_no_email' => 'This customer has no email on file',
    'pdf_render_failed' => "Couldn't generate the PDF",
    'email_send_failed' => "Couldn't send the email",
    'not_an_invoice' => 'Only invoices support this action',
    'amount_exceeds_owed' => "That's more than what's owed on this invoice",
    'already_voided' => 'This payment was already voided',
    'already_paid' => 'This invoice is already fully paid',
    'not_written_off' => "This invoice hasn't been written off",
    'subscription_required' => 'An active subscription is required to do that',
    'read_only_role' => 'Your role on this business is read-only',
    'business_limit_reached' => "You've reached the limit of 3 businesses",
    'already_member' => 'That person is already on this team',
    'no_access' => "You don't have access to that business",
    'owner_cannot_leave' => "Owners can't leave their own business",
    'not_a_member' => "You're not a member of this business",
    'email_mismatch' => 'This invite was sent to a different email address',
    'expired' => 'This invite has expired',
    'already_accepted' => 'This invite was already accepted',
    'not_found' => "We couldn't find that. It may have been removed",
    'invalid_challenge' => 'This sign-in expired. Log in again',
    'invalid_code' => "That code isn't right. Try again",
    'not_enabled' => "Two-factor sign-in isn't turned on",
    'has_admin_history' => "This account can't be deleted because it has administrator history",
    'upload_failed' => 'The upload failed. Try again',
    'invalid_file_type' => 'Choose a PNG, JPG, or WebP image',
    'no_file' => 'Choose an image first',
    'not_owner' => 'Only the business owner can change this',
    'forbidden' => "You don't have permission to use that file",
    _ => 'Something went wrong. Try again',
  };
}
