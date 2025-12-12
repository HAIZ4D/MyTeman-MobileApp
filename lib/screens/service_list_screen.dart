import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../widgets/service_card.dart';
import '../models/service.dart';
import 'application_form_screen.dart';
import 'voice_clinic_search_flow_screen.dart';
import 'bkoku_application_screen.dart';
import 'eligibility_voice_check_screen.dart';
import '../utils/haptic_feedback.dart';

/// Service list screen with grid/list view and filters
class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({super.key});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: language == 'ms' ? 'Cari perkhidmatan...' : 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Category filters and view toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: language == 'ms' ? 'Semua' : 'All',
                          isSelected: _selectedCategory == null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                        _CategoryChip(
                          label: language == 'ms' ? 'Kebajikan' : 'Welfare',
                          isSelected: _selectedCategory == 'welfare',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'welfare';
                            });
                          },
                        ),
                        _CategoryChip(
                          label: language == 'ms' ? 'Perniagaan' : 'Business',
                          isSelected: _selectedCategory == 'business',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'business';
                            });
                          },
                        ),
                        _CategoryChip(
                          label: language == 'ms' ? 'Pendidikan' : 'Education',
                          isSelected: _selectedCategory == 'education',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'education';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  tooltip: _isGridView ? 'List View' : 'Grid View',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Services list/grid
          Expanded(
            child: servicesAsync.when(
              data: (services) {
                // Filter services
                var filteredServices = services.where((service) {
                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final title = service.getTitle(language).toLowerCase();
                    final description = service.getDescription(language).toLowerCase();
                    if (!title.contains(_searchQuery) && !description.contains(_searchQuery)) {
                      return false;
                    }
                  }

                  // Category filter
                  if (_selectedCategory != null) {
                    if (!service.categories.contains(_selectedCategory)) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filteredServices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          language == 'ms' ? 'Tiada perkhidmatan dijumpai' : 'No services found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 2 : 1,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      return ServiceCard(
                        service: filteredServices[index],
                        language: language,
                        onTap: () {
                          _showServiceDetails(context, filteredServices[index], language);
                        },
                      );
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceCard(
                          service: filteredServices[index],
                          language: language,
                          onTap: () {
                            _showServiceDetails(context, filteredServices[index], language);
                          },
                        ),
                      );
                    },
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(BuildContext context, Service service, String language) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.getTitle(language),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  service.getDescription(language),
                  style: const TextStyle(fontSize: 16),
                ),
                if (service.estimatedDays != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${language == 'ms' ? 'Anggaran masa' : 'Estimated time'}: ${service.estimatedDays} ${language == 'ms' ? 'hari' : 'days'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  language == 'ms' ? 'Dokumen Diperlukan:' : 'Required Documents:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...service.requiredFields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            field.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticHelper.selection();
                      Navigator.pop(context);

                      final currentUser = ref.read(currentUserProvider);

                      // Route to appropriate screen based on service type
                      if (service.serviceId == 'peka_b40_clinic_search') {
                        // Voice-first clinic search
                        if (currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceClinicSearchFlowScreen(user: currentUser),
                            ),
                          );
                        }
                      } else if (service.serviceId == 'peka_b40_eligibility_check') {
                        // Peka B40 Eligibility Check - Voice-first
                        if (currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EligibilityVoiceCheckScreen(user: currentUser),
                            ),
                          );
                        }
                      } else if (service.serviceId == 'bkoku_application_2025') {
                        // BKOKU application with voice-first flow
                        if (currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BkokuApplicationScreen(user: currentUser),
                            ),
                          );
                        }
                      } else {
                        // Default routing for other services
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicationFormScreen(service: service),
                          ),
                        );
                      }
                    },
                    child: Text(
                      language == 'ms' ? 'Mohon Sekarang' : 'Apply Now',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}
