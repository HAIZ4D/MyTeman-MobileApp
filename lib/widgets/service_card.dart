import 'package:flutter/material.dart';
import '../models/service.dart';

/// Service card widget for displaying service information
class ServiceCard extends StatelessWidget {
  final Service service;
  final String language;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.language,
    this.onTap,
  });

  IconData _getIconData() {
    switch (service.icon) {
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'business_center':
        return Icons.business_center;
      case 'school':
        return Icons.school;
      default:
        return Icons.article;
    }
  }

  Color _getCategoryColor(BuildContext context) {
    final categories = service.categories;
    if (categories.contains('welfare') || categories.contains('social')) {
      return Colors.green;
    } else if (categories.contains('business') || categories.contains('permits')) {
      return Colors.blue;
    } else if (categories.contains('education') || categories.contains('scholarship')) {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final title = service.getTitle(language);
    final description = service.getDescription(language);
    final categoryColor = _getCategoryColor(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(),
                      size: 32,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (service.estimatedDays != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.estimatedDays} ${language == 'ms' ? 'hari' : 'days'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: service.categories.map((category) {
                  return Chip(
                    label: Text(
                      category.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: categoryColor.withValues(alpha: 0.1),
                    side: BorderSide(color: categoryColor, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
