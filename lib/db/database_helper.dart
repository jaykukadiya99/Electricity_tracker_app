import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _metersRef {
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('meters');
  }

  CollectionReference get _billingHistoryRef {
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('billingHistory');
  }

  CollectionReference get _billingRecordsRef {
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('billingRecords');
  }

  // --- Meter Operations ---
  Future<void> insertMeter(Map<String, dynamic> meter) async {
    final docRef = _metersRef.doc();
    meter['id'] = docRef.id;
    // Assign a stable sort_order based on current count so renaming never changes display order
    final countSnap = await _metersRef.count().get();
    meter['sort_order'] = (countSnap.count ?? 0);
    await docRef.set(meter);
  }

  Future<List<Map<String, dynamic>>> getAllMeters() async {
    final snapshot = await _metersRef.orderBy('sort_order').get();
    return snapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['id'] = d.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>?> getMeter(String id) async {
    final doc = await _metersRef.doc(id).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  Future<bool> isSetupComplete() async {
    try {
      final req = await _metersRef.count().get();
      return (req.count ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateMeterLatestReading(String id, double newReading) async {
    await _metersRef.doc(id).update({'latest_reading': newReading});
  }

  Future<void> updateMeterName(String id, String newName) async {
    await _metersRef.doc(id).update({'meter_name': newName});
  }

  Future<void> deleteMeter(String id) async {
    await _metersRef.doc(id).delete();
  }

  // --- Billing Operations ---
  Future<String> insertBillingHistory(Map<String, dynamic> bill) async {
    final docRef = _billingHistoryRef.doc();
    bill['id'] = docRef.id;
    await docRef.set(bill);
    return docRef.id;
  }

  Future<void> updateBillingHistoryTotals(String historyId, double totalAmount, double totalConsumption) async {
      await _billingHistoryRef.doc(historyId).update({
          'total_amount': totalAmount,
          'total_consumption': totalConsumption,
      });
  }

  Future<void> insertBillingRecord(Map<String, dynamic> record) async {
    final docRef = _billingRecordsRef.doc();
    record['id'] = docRef.id;
    await docRef.set(record);
  }

  Future<List<Map<String, dynamic>>> getBillingHistory() async {
    final snapshot = await _billingHistoryRef.orderBy('date_added', descending: true).get();
    return snapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['id'] = d.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getMonthlyReports() async {
    final snapshot = await _billingHistoryRef.orderBy('date_added', descending: true).get();
    return snapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['bill_id'] = d.id; 
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getFilteredReports({
    String? meterId,
    int? startDate,
    int? endDate,
    bool isLatestOnly = false,
  }) async {
    Query query = _billingRecordsRef;

    if (meterId != null) {
      query = query.where('meter_id', isEqualTo: meterId);
    }
    if (startDate != null) {
      query = query.where('created_at', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('created_at', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();
    final records = snapshot.docs.map((e) {
        final data = e.data() as Map<String, dynamic>;
        data['record_id'] = e.id;
        return data;
    }).toList();

    records.sort((a,b) => (b['created_at'] as int).compareTo(a['created_at'] as int));

    if (isLatestOnly) {
      final Map<String, Map<String, dynamic>> latestMap = {};
      for (var row in records) {
        String mId = row['meter_id'].toString();
        if (!latestMap.containsKey(mId)) {
          latestMap[mId] = row;
        }
      }
      final list = latestMap.values.toList();
      list.sort((a, b) {
         final nameA = a.containsKey('meter_name') ? a['meter_name'].toString() : '';
         final nameB = b.containsKey('meter_name') ? b['meter_name'].toString() : '';
         return nameA.compareTo(nameB);
      });
      return list;
    }

    return records;
  }

  Future<List<Map<String, dynamic>>> getBillingRecords(String billId) async {
    final snapshot = await _billingRecordsRef.where('bill_id', isEqualTo: billId).get();
    final docs = snapshot.docs.map((d) {
        final map = d.data() as Map<String,dynamic>;
        map['id'] = d.id;
        return map;
    }).toList();
    docs.sort((a,b) {
         final nameA = a.containsKey('meter_name') ? a['meter_name'].toString() : '';
         final nameB = b.containsKey('meter_name') ? b['meter_name'].toString() : '';
         return nameA.compareTo(nameB);
    });
    return docs;
  }

  Future<List<Map<String, dynamic>>> getMeterHistory(String meterId) async {
    final snapshot = await _billingRecordsRef
      .where('meter_id', isEqualTo: meterId)
      .get();
      
    final docs = snapshot.docs.map((d) {
        final map = d.data() as Map<String,dynamic>;
        map['id'] = d.id;
        return map;
    }).toList();
    docs.sort((a,b) => (b['created_at'] as int).compareTo(a['created_at'] as int));
    return docs;
  }

  Future<void> deleteBill(String billId) async {
    await _billingHistoryRef.doc(billId).delete();
    final childSnaps = await _billingRecordsRef.where('bill_id', isEqualTo: billId).get();
    for (var doc in childSnaps.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteBillingRecord(String recordId, String meterId, String billId, double amount, double consumption) async {
    // 1. Delete the specific record
    await _billingRecordsRef.doc(recordId).delete();
    
    // 2. Fetch remaining records for the meter to accurately determine the latest reading
    final list = await getMeterHistory(meterId);
    
    // 3. Update meter latest reading (fallback to initial if history is emptied)
    final meter = await getMeter(meterId);
    if (meter != null) {
      double latestReading = (meter['opening_reading'] as num?)?.toDouble() ?? 0.0;
      if (list.isNotEmpty) {
        latestReading = (list.first['current_reading'] as num).toDouble();
      }
      await updateMeterLatestReading(meterId, latestReading);
    }
    
    // 4. Update the umbrella billingHistory statement totals
    final remainingInBill = await getBillingRecords(billId);
    if (remainingInBill.isEmpty) {
        // If no records remain for that specific monthly bill, scrub the bill
        await _billingHistoryRef.doc(billId).delete();
    } else {
        // Otherwise, subtract the consumption and amount
        final billDoc = await _billingHistoryRef.doc(billId).get();
        if (billDoc.exists) {
            final data = billDoc.data() as Map<String, dynamic>;
            double tAmount = (data['total_amount'] as num?)?.toDouble() ?? 0.0;
            double tCons = (data['total_consumption'] as num?)?.toDouble() ?? 0.0;
            
            tAmount -= amount;
            tCons -= consumption;
            
            await _billingHistoryRef.doc(billId).update({
                'total_amount': tAmount < 0 ? 0 : tAmount,
                'total_consumption': tCons < 0 ? 0 : tCons
            });
        }
    }
  }

  Future<void> clearAllData() async {
    for (var col in [_metersRef, _billingHistoryRef, _billingRecordsRef]) {
        final snaps = await col.get();
        for (var doc in snaps.docs) {
            await doc.reference.delete();
        }
    }
  }
}
