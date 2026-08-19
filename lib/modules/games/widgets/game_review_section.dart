import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/game_model.dart';
import '../../../data/models/review_comment_model.dart';
import '../../../data/repositories/review_comment_repository.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/network/api_client.dart';

class GameReviewSection extends StatefulWidget {
  final Game game;
  final String gameId;

  const GameReviewSection({
    super.key,
    required this.game,
    required this.gameId,
  });

  @override
  State<GameReviewSection> createState() => _GameReviewSectionState();
}

class _GameReviewSectionState extends State<GameReviewSection> {
  final ReviewCommentRepository _repository = ReviewCommentRepository();

  ReviewComment? _userReview;
  List<ReviewComment> _reviews = [];
  bool _isLoadingUserReview = true;
  bool _isLoadingReviews = true;
  bool _isSubmitting = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  String? _error;

  // Form state
  int _selectedRating = 0;
  final TextEditingController _contentController = TextEditingController();
  bool _showForm = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadUserReview(), _loadReviews()]);
  }

  Future<void> _loadUserReview() async {
    setState(() {
      _isLoadingUserReview = true;
      _error = null;
    });
    try {
      final review = await _repository.getUserReview(widget.gameId);
      if (mounted) {
        setState(() {
          _userReview = review;
          _isLoadingUserReview = false;
          if (review != null) {
            _selectedRating = review.rating ?? 0;
            _contentController.text = review.content ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserReview = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadReviews({int page = 1}) async {
    setState(() {
      _isLoadingReviews = true;
    });
    try {
      final response = await _repository.getGameReviews(
        widget.gameId,
        page: page,
        limit: 10,
      );
      if (mounted) {
        setState(() {
          _reviews = response.reviewComments;
          _currentPage = response.page;
          _totalPages = response.totalPages;
          _total = response.total;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_selectedRating < 1 || _selectedRating > 5) {
      Get.snackbar('تنبيه', 'الرجاء اختيار تقييم من 1 إلى 5 نجوم');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_userReview != null) {
        // Update
        final response = await _repository.updateReview(
          _userReview!.id!,
          rating: _selectedRating,
          content: _contentController.text.isNotEmpty
              ? _contentController.text
              : null,
        );
        if (response['success'] == true && response['reviewComment'] != null) {
          setState(() {
            _userReview = ReviewComment.fromJson(response['reviewComment']);
            _showForm = false;
            _isEditing = false;
          });
          Get.snackbar('تم', 'تم تحديث تقييمك بنجاح');
          _loadReviews();
        }
      } else {
        // Create
        final response = await _repository.createReview(
          gameId: widget.gameId,
          rating: _selectedRating,
          content: _contentController.text.isNotEmpty
              ? _contentController.text
              : null,
        );
        if (response['success'] == true && response['reviewComment'] != null) {
          setState(() {
            _userReview = ReviewComment.fromJson(response['reviewComment']);
            _showForm = false;
          });
          Get.snackbar('تم', 'تم إرسال تقييمك بنجاح');
          _loadReviews();
        }
      }
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء حفظ التقييم');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteReview() async {
    if (_userReview == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التقييم'),
        content: const Text('هل أنت متأكد من حذف تقييمك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _repository.deleteReview(_userReview!.id!);
      if (response['success'] == true) {
        setState(() {
          _userReview = null;
          _selectedRating = 0;
          _contentController.clear();
          _showForm = false;
          _isEditing = false;
        });
        Get.snackbar('تم', 'تم حذف تقييمك بنجاح');
        _loadReviews();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء حذف التقييم');
    }
  }

  void _startEdit() {
    setState(() {
      _selectedRating = _userReview?.rating ?? 0;
      _contentController.text = _userReview?.content ?? '';
      _isEditing = true;
      _showForm = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _showForm = false;
      _isEditing = false;
      if (_userReview != null) {
        _selectedRating = _userReview!.rating ?? 0;
        _contentController.text = _userReview!.content ?? '';
      } else {
        _selectedRating = 0;
        _contentController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Title ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionTitle('التقييمات والمراجعات'),
        ),
        const SizedBox(height: 12),

        // ── Average Rating Summary ──
        _buildAverageRating(isDark, primaryColor),
        const SizedBox(height: 16),

        // ── User Rating Section ──
        _buildUserRatingSection(isDark, primaryColor),
        const SizedBox(height: 16),

        // ── All Reviews List ──
        _buildReviewsList(isDark, primaryColor),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: isDark
                ? AppColors.primaryDark.withValues(alpha: 0.3)
                : AppColors.primaryLight.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAverageRating(bool isDark, Color primaryColor) {
    final avgRating = widget.game.internalRating ?? 0.0;
    final ratingCount = widget.game.internalRatingCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.6)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? primaryColor.withValues(alpha: 0.2)
                : primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Star and average
            Column(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 36),
                const SizedBox(height: 4),
                Text(
                  avgRating > 0 ? avgRating.toStringAsFixed(1) : '-',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryLight,
                  ),
                ),
                Text(
                  'من 5',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Stars bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ratingCount > 0
                        ? '$ratingCount تقييم'
                        : 'لا توجد تقييمات بعد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStarRow(avgRating, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRow(
    double rating, {
    double size = 24,
    bool interactive = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = rating >= starValue;
        final half = !filled && rating >= starValue - 0.5;

        return GestureDetector(
          onTap: interactive
              ? () {
                  setState(() => _selectedRating = starValue);
                }
              : null,
          child: Icon(
            filled
                ? Icons.star_rounded
                : half
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }

  Widget _buildUserRatingSection(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.6)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? primaryColor.withValues(alpha: 0.2)
                : primaryColor.withValues(alpha: 0.1),
          ),
        ),
        child: _isLoadingUserReview
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : _showForm
            ? _buildReviewForm(isDark, primaryColor)
            : _buildUserReviewDisplay(isDark, primaryColor),
      ),
    );
  }

  Widget _buildUserReviewDisplay(bool isDark, Color primaryColor) {
    if (_userReview == null) {
      return SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            Text(
              'لم تقم بتقييم هذه اللعبة بعد',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.star_outline_rounded),
              label: const Text('قيّم اللعبة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Existing review display
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'تقييمك:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 8),
            _buildStarRow((_userReview!.rating ?? 0).toDouble(), size: 20),
            const Spacer(),
            // Edit button
            IconButton(
              onPressed: _startEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: isDark ? Colors.white70 : AppColors.primaryLight,
              ),
              tooltip: 'تعديل',
            ),
            // Delete button
            IconButton(
              onPressed: _deleteReview,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              tooltip: 'حذف',
            ),
          ],
        ),
        if (_userReview!.content != null &&
            _userReview!.content!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _userReview!.content!,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewForm(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditing ? 'تعديل تقييمك' : 'قيّم اللعبة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 12),
        // Star selector
        Center(
          child: _buildStarRow(
            _selectedRating.toDouble(),
            size: 36,
            interactive: true,
          ),
        ),
        const SizedBox(height: 12),
        // Content text field
        TextField(
          controller: _contentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'اكتب تعليقك (اختياري)...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 12),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: _cancelEdit, child: const Text('إلغاء')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEditing ? 'تحديث' : 'إرسال'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsList(bool isDark, Color primaryColor) {
    if (_isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'حدث خطأ أثناء تحميل التقييمات',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            'لا توجد تقييمات بعد. كن أول من يقيم!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionTitle('آراء اللاعبين ($_total)'),
        ),
        const SizedBox(height: 8),
        ...List.generate(_reviews.length, (index) {
          return _buildReviewCard(_reviews[index], isDark, primaryColor);
        }),
        // Pagination
        if (_totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _currentPage > 1
                      ? () => _loadReviews(page: _currentPage - 1)
                      : null,
                  child: const Text('السابق'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_currentPage من $_totalPages',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _currentPage < _totalPages
                      ? () => _loadReviews(page: _currentPage + 1)
                      : null,
                  child: const Text('التالي'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReviewCard(
    ReviewComment review,
    bool isDark,
    Color primaryColor,
  ) {
    final userName =
        review.userId?.userName ??
        '${review.userId?.firstName ?? ''} ${review.userId?.lastName ?? ''}'
            .trim();
    final displayName = userName.isNotEmpty ? userName : 'مستخدم';
    final timeAgo = review.createdAt != null
        ? _formatTimeAgo(review.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              SafeCachedAvatar(
                user: review.userId!,
                radius: 16,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.primaryLight,
                      ),
                    ),
                    if (timeAgo.isNotEmpty)
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              _buildStarRow((review.rating ?? 0).toDouble(), size: 16),
            ],
          ),
          if (review.content != null && review.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.content!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      timeago.setLocaleMessages('ar', timeago.ArMessages());
      return timeago.format(date, locale: 'ar');
    } catch (_) {
      return '';
    }
  }
}
