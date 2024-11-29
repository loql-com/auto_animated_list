import 'package:auto_animated_list/auto_animated_list.dart';
import 'package:auto_animated_list/src/custom_sliver_animated_list.dart';
import 'package:auto_animated_list/src/util/sliver_child_separated_builder_delegate.dart';
import 'package:flutter/material.dart' hide AnimatedItemBuilder;

import 'src.dart';

/// A Flutter ListView that implicitly animates between the changes of two lists.
class ImplicitlyAnimatedList<E extends Object> extends StatelessWidget {
  /// The current data that this [ImplicitlyAnimatedList] should represent.
  final List<E> items;

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  final AnimatedItemBuilder<Widget, E> itemBuilder;

  /// Called to build widgets that get placed between
  /// itemBuilder(context, index) and itemBuilder(context, index + 1).
  final NullableIndexedWidgetBuilder? separatorBuilder;

  /// An optional builder when an item was removed from the list.
  ///
  /// If not specified, the [ImplicitlyAnimatedList] uses the [itemBuilder] with
  /// the animation reversed.
  final RemovedItemBuilder<Widget, E>? removeItemBuilder;

  /// An optional builder when an item in the list was changed but not its position.
  ///
  /// The [UpdatedItemBuilder] animation will run from 1 to 0 and back to 1 again, while
  /// the item parameter will be the old item in the first half of the animation and the new item
  /// in the latter half of the animation. This allows you for example to fade between the old and
  /// the new item.
  ///
  /// If not specified, changes will appear instantaneously.
  final UpdatedItemBuilder<Widget, E>? updateItemBuilder;

  /// Called by the DiffUtil to decide whether two object represent the same Item.
  /// For example, if your items have unique ids, this method should check their id equality.
  final ItemDiffUtil<E> areItemsTheSame;

  /// The duration of the animation when an item was inserted into the list.
  final Duration insertDuration;

  /// The duration of the animation when an item was removed from the list.
  final Duration removeDuration;

  /// The duration of the animation when an item changed in the list.
  final Duration updateDuration;

  /// Whether to spawn a new isolate on which to calculate the diff on.
  ///
  /// Usually you wont have to specify this value as the MyersDiff implementation will
  /// use its own metrics to decide, whether a new isolate has to be spawned or not for
  /// optimal performance.
  final bool? spawnIsolate;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// The clip behavior to be used by the scroll view.
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// When set provides access to extents of individual children.
  /// [ListController] can also be used to jump to a specific item in the list.
  final ListController? listController;

  /// Optional method that can be used to override default estimated extent for
  /// each item. Initially all extents are estimated and then as the items are laid
  /// out, either through scrolling or [extentPrecalculationPolicy], the actual
  /// extents are calculated and the scroll offset is adjusted to account for
  /// the difference between estimated and actual extents.
  ///
  /// The item index argument is nullable. If all estimated items have same extent,
  /// the implementation should return non-zero extent for the `null` index. This saves
  /// calls to extent estimation provider for large lists.
  /// If each item has different extent, return zero for the `null` index.
  final ExtentEstimationProvider? extentEstimation;

  /// Optional policy that can be used to asynchronously precalculate the extents
  /// of the items in the list. This can be useful allow precise scrolling on small
  /// lists where the difference between estimated and actual extents may be noticeable
  /// when interacting with the scrollbar. For larger lists precalculating extent
  /// has diminishing benefits since the error for each item does not impact the
  /// overall scroll position as much.
  final ExtentPrecalculationPolicy? extentPrecalculationPolicy;

  /// Whether the items in cache area should be built delayed.
  /// This is an optimization that kicks in during fast scrolling, when
  /// all items are being replaced on every frame.
  /// With [delayPopulatingCacheArea] set to `true`, the items in cache area
  /// are only built after the scrolling slows down.
  final bool delayPopulatingCacheArea;

  /// Whether children with keepAlive should be laid out.
  /// Setting this to `true` ensures that layout for kept alive children is
  /// maintained and proper paint transform is applied.
  final bool layoutKeptAliveChildren;

  /// Creates a Flutter ListView that implicitly animates between the changes
  /// of two lists.
  const ImplicitlyAnimatedList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.areItemsTheSame,
    this.separatorBuilder,
    this.removeItemBuilder,
    this.updateItemBuilder,
    this.insertDuration = const Duration(milliseconds: 500),
    this.removeDuration = const Duration(milliseconds: 500),
    this.updateDuration = const Duration(milliseconds: 500),
    this.spawnIsolate,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.clipBehavior = Clip.hardEdge,
    this.listController,
    this.extentEstimation,
    this.extentPrecalculationPolicy,
    this.delayPopulatingCacheArea = true,
    this.layoutKeptAliveChildren = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final separatorBuilder = this.separatorBuilder;

    return CustomScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      clipBehavior: clipBehavior,
      slivers: <Widget>[
        SliverPadding(
          padding: padding ?? const EdgeInsets.all(0),
          sliver: separatorBuilder == null
              ? SliverImplicitlyAnimatedList<E>(
                  items: items,
                  itemBuilder: itemBuilder,
                  areItemsTheSame: areItemsTheSame,
                  updateItemBuilder: updateItemBuilder,
                  removeItemBuilder: removeItemBuilder,
                  insertDuration: insertDuration,
                  removeDuration: removeDuration,
                  updateDuration: updateDuration,
                  spawnIsolate: spawnIsolate,
                )
              : SliverImplicitlyAnimatedList<E>.separated(
                  items: items,
                  itemBuilder: itemBuilder,
                  separatorBuilder: separatorBuilder,
                  areItemsTheSame: areItemsTheSame,
                  updateItemBuilder: updateItemBuilder,
                  removeItemBuilder: removeItemBuilder,
                  insertDuration: insertDuration,
                  removeDuration: removeDuration,
                  updateDuration: updateDuration,
                  spawnIsolate: spawnIsolate,
                ),
        ),
      ],
    );
  }
}

/// A Flutter Sliver that implicitly animates between the changes of two lists.
class SliverImplicitlyAnimatedList<E extends Object>
    extends ImplicitlyAnimatedListBase<Widget, E> {
  /// Creates a Flutter Sliver that implicitly animates between the changes of two lists.
  ///
  /// {@template implicitly_animated_reorderable_list.constructor}
  /// The [items] parameter represents the current items that should be displayed in
  /// the list.
  ///
  /// The [itemBuilder] callback is used to build each child as needed. The parent must
  /// be a [Reorderable] widget.
  ///
  /// The [areItemsTheSame] callback is called by the DiffUtil to decide whether two objects
  /// represent the same item. For example, if your items have unique ids, this method should
  /// check their id equality.
  ///
  /// The [onReorderFinished] callback is called in response to when the dragged item has
  /// been released and animated to its final destination. Here you should update
  /// the underlying data in your model/bloc/database etc.
  ///
  /// The [spawnIsolate] flag indicates whether to spawn a new isolate on which to
  /// calculate the diff between the lists. Usually you wont have to specify this
  /// value as the MyersDiff implementation will use its own metrics to decide, whether
  /// a new isolate has to be spawned or not for optimal performance.
  /// {@endtemplate}
  const SliverImplicitlyAnimatedList({
    Key? key,
    required List<E> items,
    required AnimatedItemBuilder<Widget, E> itemBuilder,
    required ItemDiffUtil<E> areItemsTheSame,
    RemovedItemBuilder<Widget, E>? removeItemBuilder,
    UpdatedItemBuilder<Widget, E>? updateItemBuilder,
    Duration insertDuration = const Duration(milliseconds: 500),
    Duration removeDuration = const Duration(milliseconds: 500),
    Duration updateDuration = const Duration(milliseconds: 500),
    bool? spawnIsolate,
    super.listController,
    super.delayPopulatingCacheArea = true,
    super.layoutKeptAliveChildren = false,
    super.extentEstimation,
    super.extentPrecalculationPolicy,
  }) : super(
          key: key,
          items: items,
          itemBuilder: itemBuilder,
          delegateBuilder: null,
          areItemsTheSame: areItemsTheSame,
          removeItemBuilder: removeItemBuilder,
          updateItemBuilder: updateItemBuilder,
          insertDuration: insertDuration,
          removeDuration: removeDuration,
          updateDuration: updateDuration,
          spawnIsolate: spawnIsolate,
        );

  /// Creates a Flutter Sliver that implicitly animates between the changes of two lists.
  ///
  /// {@template implicitly_animated_reorderable_list.constructor}
  /// The [items] parameter represents the current items that should be displayed in
  /// the list.
  ///
  /// The [itemBuilder] callback is used to build each child as needed. The parent must
  /// be a [Reorderable] widget.
  ///
  /// The [separatorBuilder] is the widget that gets placed between
  /// itemBuilder(context, index) and itemBuilder(context, index + 1).
  ///
  /// The [areItemsTheSame] callback is called by the DiffUtil to decide whether two objects
  /// represent the same item. For example, if your items have unique ids, this method should
  /// check their id equality.
  ///
  /// The [onReorderFinished] callback is called in response to when the dragged item has
  /// been released and animated to its final destination. Here you should update
  /// the underlying data in your model/bloc/database etc.
  ///
  /// The [spawnIsolate] flag indicates whether to spawn a new isolate on which to
  /// calculate the diff between the lists. Usually you wont have to specify this
  /// value as the MyersDiff implementation will use its own metrics to decide, whether
  /// a new isolate has to be spawned or not for optimal performance.
  /// {@endtemplate}
  SliverImplicitlyAnimatedList.separated({
    Key? key,
    required List<E> items,
    required AnimatedItemBuilder<Widget, E> itemBuilder,
    required ItemDiffUtil<E> areItemsTheSame,
    required NullableIndexedWidgetBuilder separatorBuilder,
    RemovedItemBuilder<Widget, E>? removeItemBuilder,
    UpdatedItemBuilder<Widget, E>? updateItemBuilder,
    Duration insertDuration = const Duration(milliseconds: 500),
    Duration removeDuration = const Duration(milliseconds: 500),
    Duration updateDuration = const Duration(milliseconds: 500),
    bool? spawnIsolate,
    super.listController,
    super.delayPopulatingCacheArea = true,
    super.layoutKeptAliveChildren = false,
    super.extentEstimation,
    super.extentPrecalculationPolicy,
  }) : super(
          key: key,
          items: items,
          itemBuilder: itemBuilder,
          delegateBuilder: (builder, itemCount) =>
              SliverChildSeparatedBuilderDelegate(
            itemBuilder: builder,
            separatorBuilder: separatorBuilder,
            itemCount: itemCount,
          ),
          areItemsTheSame: areItemsTheSame,
          removeItemBuilder: removeItemBuilder,
          updateItemBuilder: updateItemBuilder,
          insertDuration: insertDuration,
          removeDuration: removeDuration,
          updateDuration: updateDuration,
          spawnIsolate: spawnIsolate,
        );

  @override
  _SliverImplicitlyAnimatedListState<E> createState() =>
      _SliverImplicitlyAnimatedListState<E>();
}

class _SliverImplicitlyAnimatedListState<E extends Object>
    extends ImplicitlyAnimatedListBaseState<Widget,
        SliverImplicitlyAnimatedList<E>, E> {
  @override
  Widget build(BuildContext context) {
    return CustomSliverAnimatedList(
      key: animatedListKey,
      initialItemCount: newList.length,
      itemBuilder: (context, index, animation) {
        final E? item = data.getOrNull(index) ??
            newList.getOrNull(index) ??
            oldList.getOrNull(index);
        final didChange = changes[item] != null;

        if (item == null) {
          return Container();
        } else if (updateItemBuilder != null && didChange) {
          return buildUpdatedItemWidget(item);
        } else {
          return itemBuilder(context, animation, item, index);
        }
      },
      delegateBuilder: widget.delegateBuilder,
      listController: widget.listController,
      delayPopulatingCacheArea: widget.delayPopulatingCacheArea,
      extentEstimation: widget.extentEstimation,
      extentPrecalculationPolicy: widget.extentPrecalculationPolicy,
      layoutKeptAliveChildren: widget.layoutKeptAliveChildren,
    );
  }
}
