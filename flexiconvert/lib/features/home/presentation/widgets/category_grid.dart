import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'title': 'PDF Tools', 'icon': Icons.picture_as_pdf, 'color': Colors.red, 'gradient': AppColors.pdfGradient, 'route': RouteConstants.pdf},
    {'title': 'Image Tools', 'icon': Icons.image, 'color': Colors.green, 'gradient': AppColors.imageGradient, 'route': RouteConstants.image},
    {'title': 'Video Tools', 'icon': Icons.videocam, 'color': Colors.blue, 'gradient': AppColors.videoGradient, 'route': RouteConstants.video},
    {'title': 'Audio Tools', 'icon': Icons.audiotrack, 'color': Colors.orange, 'gradient': AppColors.audioGradient, 'route': RouteConstants.audio},
    {'title': 'Convert PDF', 'icon': Icons.description, 'color': Colors.purple, 'gradient': AppColors.secondaryGradient, 'route': RouteConstants.document},
    {'title': 'Archive', 'icon': Icons.folder_zip, 'color': Colors.brown, 'gradient': AppColors.primaryGradient, 'route': RouteConstants.archive},
    {'title': 'QR Tools', 'icon': Icons.qr_code_2, 'color': Colors.teal, 'gradient': AppColors.imageGradient, 'route': RouteConstants.qr},
    {'title': 'More', 'icon': Icons.grid_view, 'color': Colors.indigo, 'gradient': AppColors.primaryGradient, 'route': null},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0, // adjusted aspect ratio to prevent clipping
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _CategoryItem(
          title: cat['title'] as String,
          icon: cat['icon'] as IconData,
          color: cat['color'] as Color,
          gradient: cat['gradient'] as Gradient,
          onTap: () => _navigate(context, cat),
        );
      },
    );
  }

  void _navigate(BuildContext context, Map<String, dynamic> cat) {
    final route = cat['route'] as String?;
    if (route != null) {
      context.go('${RouteConstants.home}/$route');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cat['title']} is coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
