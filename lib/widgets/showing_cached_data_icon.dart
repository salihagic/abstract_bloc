import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

class ShowingCachedDataIcon extends StatelessWidget {
  final void Function(BuildContext context)? onReload;
  final bool allowReload;
  final IconData icon;
  final Color iconColor;

  const ShowingCachedDataIcon({
    Key? key,
    this.onReload,
    this.allowReload = true,
    this.icon = Icons.info_outline,
    this.iconColor = const Color(0xFFC42A03),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => InfoDialog(
          child: _Content(allowReload: allowReload),
          showCancelButton: allowReload,
          onApplyText: allowReload ? 'Reload' : null,
          onApply: () {
            if (allowReload) {
              onReload?.call(context);
            }
          },
        ),
      ),
      borderRadius: BorderRadius.circular(50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          color: Colors.white.withOpacity(0.5),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final bool allowReload;

  const _Content({
    Key? key,
    this.allowReload = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Showing cached data',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        if (allowReload) ...{
          SizedBox(height: 15),
          Text(
            'There was an error, please try again',
            textAlign: TextAlign.center,
          ),
        },
      ],
    );
  }
}
