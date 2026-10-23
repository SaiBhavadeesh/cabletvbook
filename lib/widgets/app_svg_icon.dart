import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppSvgIconType {
  areas,
  customers,
  collections,
  addCustomer,
  addArea,
  locationPin,
  setTopBox,
  call,
  copy,
  settings,
  profile,
  moreVertical,
  shield,
  help,
  terms,
  logout,
}

class AppSvgIcon extends StatelessWidget {
  final AppSvgIconType icon;
  final Color? color;
  final double size;

  const AppSvgIcon(
    this.icon, {
    super.key,
    this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? IconTheme.of(context).color ?? const Color(0xFF18181B);
    final svg = _getSvg(icon);

    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        svg,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
      ),
    );
  }

  static String _getSvg(AppSvgIconType type) {
    switch (type) {
      case AppSvgIconType.areas:
        // Folded coverage map with route seams
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M3 6l6-3 6 3 6-3v15l-6 3-6-3-6 3V6z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M9 3v15M15 6v15" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case AppSvgIconType.customers:
        // Dual subscriber silhouettes
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<circle cx="9" cy="7" r="4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M22 21v-2a4 4 0 0 0-3-3.87" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
<path d="M16 3.13a4 4 0 0 1 0 7.75" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case AppSvgIconType.collections:
        // Indian Rupee (₹) wallet ledger
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect x="2" y="5" width="20" height="15" rx="3.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M15 10h5a2 2 0 0 1 2 2v1a2 2 0 0 1-2 2h-5a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.8"/>
<circle cx="17.5" cy="12.5" r="1" fill="currentColor"/>
<path d="M6 9h4.5M6 11.2h4M6 9v6M8.5 9a1.8 1.8 0 0 1 0 3.6H6l3.5 3.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case AppSvgIconType.addCustomer:
        // Clear subscriber silhouette with distinct bold plus
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M15 19v-1a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v1" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<circle cx="8.5" cy="7" r="4" stroke="currentColor" stroke-width="2"/>
<path d="M19 8v6M16 11h6" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case AppSvgIconType.addArea:
        // Balanced plus emblem
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case AppSvgIconType.locationPin:
        // Territory map pin
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 21c4-4.5 7-8.5 7-12a7 7 0 1 0-14 0c0 3.5 3 7.5 7 12z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<circle cx="12" cy="9" r="2.5" stroke="currentColor" stroke-width="1.8"/>
</svg>''';

      case AppSvgIconType.setTopBox:
        // Cable Set-Top Box with LEDs & port
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect x="2" y="7" width="20" height="11" rx="2.5" stroke="currentColor" stroke-width="1.8"/>
<circle cx="6" cy="12.5" r="1.2" fill="currentColor"/>
<circle cx="9.5" cy="12.5" r="1.2" fill="currentColor"/>
<line x1="14" y1="12.5" x2="18" y2="12.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
<path d="M7 7V4M17 7V4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case AppSvgIconType.call:
        // Telephone handset
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case AppSvgIconType.copy:
        // Layered smart cards
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect x="8" y="8" width="13" height="13" rx="3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M4 16c-1.1 0-2-.9-2-2V5c0-1.1.9-2 2-2h9c1.1 0 2 .9 2 2" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case AppSvgIconType.settings:
        // Geometric gear cog
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.8"/>
<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case AppSvgIconType.profile:
        // Operator profile
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="1.8"/>
<path d="M5.5 21a6.5 6.5 0 0 1 13 0" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case AppSvgIconType.moreVertical:
        // Triple dots
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="12" cy="5" r="1.5" fill="currentColor"/>
<circle cx="12" cy="12" r="1.5" fill="currentColor"/>
<circle cx="12" cy="19" r="1.5" fill="currentColor"/>
</svg>''';

      case AppSvgIconType.shield:
        // Verified security shield
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M9 12l2 2 4-4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

      case AppSvgIconType.help:
        // Support bubble
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M21 12a9 9 0 0 0-9-9 9 9 0 0 0-9 9c0 1.7.5 3.3 1.4 4.7L3 21l4.4-1.4c1.3.9 2.9 1.4 4.6 1.4a9 9 0 0 0 9-9z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M12 17h.01M9.5 9.5a2.5 2.5 0 0 1 4.5 1.3c0 1.7-2 2.2-2 3.7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case AppSvgIconType.terms:
        // Document sheet
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M14 2v6h6M16 13H8M16 17H8M10 9H8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
</svg>''';

      case AppSvgIconType.logout:
        // Door logout
        return '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';
    }
  }
}
