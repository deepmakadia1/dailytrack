import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Standard screen frame (spec §15.3, §15.4): app bar, side padding (16 dp,
/// or 24 dp on wide screens), content centered at max 600 dp, the FAB above
/// an optional banner slot, and safe areas. The banner slot takes no space
/// when it is null (spec §15.8).
class AppScaffold extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    super.key,
    this.actions = const [],
    this.fab,
    this.bannerSlot,
    this.bottomBar,
    this.showBack = true,
    this.largeTitle = false,
    this.padBody = true,
    this.titleWidget,
    this.toolbarHeight,
  });

  /// Plain title; also the semantic name of the screen.
  final String title;

  /// Replaces the [title] text, e.g. DSH-01's greeting and date.
  final Widget? titleWidget;

  /// App bar height when [titleWidget] needs more than one line.
  final double? toolbarHeight;
  final Widget body;
  final List<Widget> actions;
  final Widget? fab;
  final Widget? bannerSlot;

  /// Sticky form actions (§15.3 "primary button sticky at the bottom and
  /// lifted above the keyboard"), e.g. the EXP-02 keypad and Save. Placed
  /// above [bannerSlot]; snackbars appear above it, never over it.
  final Widget? bottomBar;

  /// Shows the automatic back button when the route can pop.
  final bool showBack;

  /// Uses `headlineSmall` for the title (top-level screens).
  final bool largeTitle;

  /// Applies the side padding to [body]. Lists that pad their own rows can
  /// turn this off.
  final bool padBody;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        toolbarHeight: toolbarHeight,
        title:
            titleWidget ??
            Text(title, style: largeTitle ? textTheme.headlineSmall : null),
        actions: actions,
      ),
      floatingActionButton: fab,
      bottomNavigationBar: bottomBar == null
          ? bannerSlot
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: _ContentWidth(
                    padBody: padBody,
                    child: SafeArea(
                      top: false,
                      bottom: bannerSlot == null,
                      child: bottomBar!,
                    ),
                  ),
                ),
                ?bannerSlot,
              ],
            ),
      body: SafeArea(
        top: false,
        bottom: bannerSlot == null && bottomBar == null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pad = padBody
                ? tokens.sidePadding(constraints.maxWidth)
                : 0.0;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: body,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Applies the screen's side padding and max content width (§15.2).
class _ContentWidth extends StatelessWidget {
  const new({required this.padBody, required this.child});

  final bool padBody;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = padBody ? tokens.sidePadding(constraints.maxWidth) : 0.0;
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
