import 'package:sqflite_common/sqlite_api.dart';
import 'migration.dart';

/// Database Version 7: Delivery and Payment details for approved adoptions,
/// plus email notification records sent to adopters.
class SchemaV7 implements Migration {
  @override
  int get version => 7;

  @override
  Future<void> up(Database db) async {
    // 1. Add delivery & handover columns to adoption_requests
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN delivery_method TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN delivery_address TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN delivery_date TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN delivery_instructions TEXT;');

    // 2. Add payment columns to adoption_requests
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN payment_method TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN payment_amount REAL;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN payment_instructions TEXT;');

    // 3. Add approval message & email timestamp to adoption_requests
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN approval_message TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN email_sent_to TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN email_sent_at TEXT;');

    // 4. Create email_notifications table for storing emails sent to adopters
    await db.execute('''
      CREATE TABLE IF NOT EXISTS email_notifications (
        id TEXT PRIMARY KEY,
        request_id TEXT NOT NULL,
        sender_id TEXT,
        recipient_id TEXT NOT NULL,
        recipient_email TEXT NOT NULL,
        subject TEXT NOT NULL,
        body_text TEXT NOT NULL,
        delivery_details TEXT,
        payment_details TEXT,
        created_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        FOREIGN KEY (request_id) REFERENCES adoption_requests(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_email_notifications_recipient ON email_notifications(recipient_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_email_notifications_request ON email_notifications(request_id);');
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS email_notifications;');
  }
}
