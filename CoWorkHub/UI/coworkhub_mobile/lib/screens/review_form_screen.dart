import 'package:coworkhub_mobile/models/review.dart';
import 'package:coworkhub_mobile/models/space_unit.dart';
import 'package:coworkhub_mobile/providers/review_provider.dart';
import 'package:coworkhub_mobile/providers/space_unit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/flushbar_helper.dart';

class ReviewFormScreen extends StatefulWidget {
  final int spaceUnitId;
  final int? reservationId;
  final Review? existingReview;

  const ReviewFormScreen({
    super.key,
    required this.spaceUnitId,
    this.reservationId,
    this.existingReview,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  TextEditingController _commentController = TextEditingController();
  bool _loading = false;
  SpaceUnit? _spaceUnit;
  bool _loadingSpaceUnit = true;

  @override
  void initState() {
    super.initState();

    // Ako editujemo postojeću recenziju, popuni polja
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
    }

    _loadSpaceUnit();
  }

  Future<void> _loadSpaceUnit() async {
    try {
      final provider = context.read<SpaceUnitProvider>();
      final result = await provider.getById(widget.spaceUnitId);

      setState(() {
        _spaceUnit = result;
        _loadingSpaceUnit = false;
      });
    } catch (e) {
      _loadingSpaceUnit = false;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      showTopFlushBar(
        context: context,
        message: "Molimo ocijenite i napišite komentar",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (widget.existingReview != null) {
        await context.read<ReviewProvider>().update(
          widget.existingReview!.reviewsId,
          {"rating": _rating, "comment": _commentController.text},
        );
      } else {
        await context.read<ReviewProvider>().insert({
          "reservationId": widget.reservationId,
          "rating": _rating,
          "comment": _commentController.text,
        });
      }

      Navigator.pop(context, true);
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: "Greška: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.existingReview == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Potvrda brisanja"),
        content: const Text("Da li ste sigurni da želite obrisati recenziju?"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Da", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Ne"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);

    final provider = context.read<ReviewProvider>();

    try {
      await provider.delete(widget.existingReview!.reviewsId);
      showTopFlushBar(
        context: context,
        message: "Recenzija je obrisana",
        backgroundColor: Colors.green,
      );
      Navigator.pop(context, true);
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: "Greška: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReview != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Uredi recenziju" : "Ostavi recenziju",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IME SPACE UNITA
                      if (_loadingSpaceUnit)
                        const Center(child: CircularProgressIndicator())
                      else if (_spaceUnit != null)
                        Text(
                          _spaceUnit!.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                      const SizedBox(height: 12),

                      // COMMENT
                      TextFormField(
                        controller: _commentController,
                        maxLines: 5,
                        validator: (v) => (v == null || v.isEmpty)
                            ? "Molimo unesite komentar"
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Komentar",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // TEKST IZNAD RATINGA
                      const Text(
                        "Ocijenite prostor",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // RATING
                      Row(
                        children: List.generate(
                          5,
                          (i) => IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              i < _rating ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = i + 1;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // DUGMAD
                      Row(
                        children: [
                          // if (isEdit)
                          //   Expanded(
                          //     child: ElevatedButton(
                          //       onPressed: _delete,
                          //       style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors.red,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(8),
                          //         ),
                          //       ),
                          //       child: const Text(
                          //         "Obriši",
                          //         style: TextStyle(
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.w600,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // if (isEdit) const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isEdit ? "Sačuvaj" : "Pošalji",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
