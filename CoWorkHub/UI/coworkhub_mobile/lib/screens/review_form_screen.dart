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
                      // Ime space unita
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

                      // Komentar
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

                      // Tekst iznad ratinga
                      const Text(
                        "Ocijenite prostor",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Rating
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

                      // Dugmad
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
