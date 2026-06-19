import 'package:flutter/material.dart';

class GroupList extends StatelessWidget {
  final List<String> groups;
  final String? selectedGroup;
  final Function(String) onGroupSelected;

  const GroupList({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.onGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: groups.map((group) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(group),
              selected: selectedGroup == group,
              onSelected: (_) => onGroupSelected(group),
            ),
          );
        }).toList(),
      ),
    );
  }
}