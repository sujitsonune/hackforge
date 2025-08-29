import 'package:flutter/material.dart';

import '../../../core/constants/ott_platforms.dart';

class PlatformDropdown extends StatefulWidget {
  final OTTPlatform? selectedPlatform;
  final Function(OTTPlatform?) onPlatformSelected;

  const PlatformDropdown({
    super.key,
    this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  State<PlatformDropdown> createState() => _PlatformDropdownState();
}

class _PlatformDropdownState extends State<PlatformDropdown> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...OTTPlatforms.categories];
    
    return Column(
      children: [
        // Search Field
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search Platform',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Category Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Platform Grid
        _buildPlatformGrid(),
      ],
    );
  }

  Widget _buildPlatformGrid() {
    List<OTTPlatform> filteredPlatforms = OTTPlatforms.platforms;

    // Filter by category
    if (_selectedCategory != 'All') {
      filteredPlatforms = filteredPlatforms
          .where((platform) => platform.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredPlatforms = filteredPlatforms
          .where((platform) =>
              platform.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (filteredPlatforms.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text('No platforms found'),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: filteredPlatforms.length + 1, // +1 for custom option
        itemBuilder: (context, index) {
          if (index == filteredPlatforms.length) {
            return _buildCustomPlatformTile();
          }

          final platform = filteredPlatforms[index];
          final isSelected = widget.selectedPlatform?.id == platform.id;

          return _buildPlatformTile(platform, isSelected);
        },
      ),
    );
  }

  Widget _buildPlatformTile(OTTPlatform platform, bool isSelected) {
    return InkWell(
      onTap: () => widget.onPlatformSelected(platform),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Platform Icon/Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(int.parse(platform.color.replaceFirst('#', '0xFF'))),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  platform.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              platform.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (platform.popularPlans.isNotEmpty)
              Text(
                '₹${platform.popularPlans.first.toInt()}+',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPlatformTile() {
    final isSelected = widget.selectedPlatform == null;

    return InkWell(
      onTap: () => widget.onPlatformSelected(null),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Custom\nPlatform',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}