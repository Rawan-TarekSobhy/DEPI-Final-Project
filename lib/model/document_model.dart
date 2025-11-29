class Documents
{
  final String? docId;
  final String file_Url;
  final String file_name;
  final String? userId;
  final DateTime? created_at;
  final String? local_direct; // 💡 المسار المحلي للملف
  final bool is_synced; // 💡 حالة المزامنة

  Documents({
    this.userId,
    this.docId,
    required this.file_name,
    required this.file_Url,
    this.created_at,
    this.local_direct, // 💡 إضافة المسار المحلي
    this.is_synced = true, // 💡 الافتراضي للملفات المجلوبة
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    final String? createdAtString = json['created_at']?.toString();

    final DateTime? parsedDate = createdAtString != null
        ? DateTime.parse(createdAtString).toLocal()
        : null;

    return Documents(
      created_at: parsedDate,
      docId: json['doc_id']?.toString(), // ✅ تصحيح: تم التأكد من قراءة docId
      file_Url: json['file_url'] as String? ?? '', // قد يكون فارغاً إذا كان الملف أوفلاين
      file_name: json['file_name'] as String,
      userId: json['user_id'] as String?,
      local_direct: json['local_direct'] as String?, // 💡 قراءة المسار المحلي
      is_synced: json['is_synced'] as bool? ?? true, // 💡 قراءة حالة المزامنة
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'file_name': file_name,
      'file_url': file_Url,
      'user_id': userId,
      'local_direct': local_direct, // 💡 إرسال المسار المحلي
      'is_synced': is_synced, // 💡 إرسال حالة المزامنة
    };
    if (docId != null) {
      json['doc_id'] = docId;
    }
    return json;
  }

  // دالة مساعدة لتسهيل تعديل حالة المزامنة
  Documents copyWith({
    String? docId,
    String? file_Url,
    String? file_name,
    String? userId,
    DateTime? created_at,
    String? local_direct,
    bool? is_synced,
  }) {
    return Documents(
      docId: docId ?? this.docId,
      file_Url: file_Url ?? this.file_Url,
      file_name: file_name ?? this.file_name,
      userId: userId ?? this.userId,
      created_at: created_at ?? this.created_at,
      local_direct: local_direct ?? this.local_direct,
      is_synced: is_synced ?? this.is_synced,
    );
  }
}