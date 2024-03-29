import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

abstract class CustomRenderObjectWidget extends RenderObjectWidget {

  CustomRenderObjectWidget({
    Key? key,
    required this.children,
  }) : assert(_debugValidateSlots(children.keys.toList())),
       super(key: key);

  final Map<dynamic, Widget> children;

  static bool _debugValidateSlots(List<dynamic> slots) {
    if (slots.any((dynamic slot) => slot == null))
      return false;

    return true;
  }

  @override
  CustomRenderObjectElement createElement() => CustomRenderObjectElement(this);

  @override
  CustomRenderObjectMixin createRenderObject(BuildContext context);
}

class CustomRenderObjectElement extends RenderObjectElement {

  CustomRenderObjectElement(CustomRenderObjectWidget widget) : super(widget);

  @override
  CustomRenderObjectWidget get widget => super.widget as CustomRenderObjectWidget;

  @override
  CustomRenderObjectMixin get renderObject => super.renderObject as CustomRenderObjectMixin;

  final Map<dynamic, Element> _slotToChild = Map<dynamic, Element>();
  final Map<Element, dynamic> _childToSlot = Map<Element, dynamic>();

  @override
  void visitChildren(visitor) {
    for (final Element child in _childToSlot.keys)
      visitor(child);
  }

  @override
  void mount(Element? parent, newSlot) {
    super.mount(parent, newSlot);
    final Map<dynamic, Widget> children = widget.children;
    for (final MapEntry<dynamic, Widget> entry in children.entries) {
      final dynamic slot = entry.key;
      final Element child = inflateWidget(entry.value, slot);
      _slotToChild[slot] = child;
      _childToSlot[child] = slot;
    }
  }

  @override
  void update(RenderObjectWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);

    final List<dynamic> slotsToRemove = _slotToChild.keys.toList();
    final Map<dynamic, Widget> newChildren = widget.children;

    for (final MapEntry<dynamic, Widget> entry in newChildren.entries) {
      final dynamic slot = entry.key;
      final Element? oldChild = _slotToChild[slot];
      final Element newChild = updateChild(oldChild, entry.value, slot)!;

      if (oldChild != null)
        _childToSlot.remove(oldChild);

      _slotToChild[slot] = newChild;
      _childToSlot[newChild] = slot;
      slotsToRemove.remove(slot);
    }

    for (final dynamic slot in slotsToRemove) {
      final Element removedChild = _slotToChild.remove(slot)!;
      _childToSlot.remove(removedChild);
      deactivateChild(removedChild);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_slotToChild.values.contains(child));
    assert(_childToSlot.keys.contains(child));
    final dynamic slot = _childToSlot.remove(child);
    _slotToChild.remove(slot);
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(RenderObject child, dynamic slot) {
    assert(renderObject.debugValidateChildType(child));
    renderObject.insert(child, slot);
  }

  @override
  void moveRenderObjectChild(RenderObject child, dynamic oldSlot, dynamic newSlot) {
    assert(false, 'not reachable');
  }

  @override
  void removeRenderObjectChild(RenderObject child, dynamic slot) {
    assert(child.parent == renderObject);
    renderObject.remove(child);
  }
}

mixin CustomRenderObjectMixin<ChildType extends RenderObject> on RenderObject {

  bool debugValidateChildType(RenderObject child) {
    assert(() {
      if (child is! ChildType) {
        throw FlutterError(
          'A $runtimeType expected a child of type $ChildType but received a '
          'child of type ${child.runtimeType}.\n'
          'RenderObjects expect specific types of children because they '
          'coordinate with their children during layout and paint. For '
          'example, a RenderSliver cannot be the child of a RenderBox because '
          'a RenderSliver does not understand the RenderBox layout protocol.\n'
          '\n'
          'The $runtimeType that expected a $ChildType child was created by:\n'
          '  $debugCreator\n'
          '\n'
          'The ${child.runtimeType} that did not match the expected child type '
          'was created by:\n'
          '  ${child.debugCreator}\n'
        );
      }
      return true;
    }());
    return true;
  }

  final Map<dynamic, ChildType> _slotToChild = Map<dynamic, ChildType>();
  final Map<ChildType, dynamic> _childToSlot = Map<ChildType, dynamic>();

  void insert(RenderObject child, dynamic slot) {
    assert(child is ChildType);
    adoptChild(child);
    _slotToChild[slot] = child as ChildType;
    _childToSlot[child] = slot;
  }

  void remove(RenderObject child) {
    assert(_slotToChild.values.contains(child));
    assert(_childToSlot.keys.contains(child));
    final dynamic slot = _childToSlot.remove(child);
    _slotToChild.remove(slot);
    dropChild(child);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    for (final ChildType child in _childToSlot.keys)
      visitor(child);
  }

  @override
  void redepthChildren() {
    for (final ChildType child in _childToSlot.keys)
      redepthChild(child);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final ChildType child in _childToSlot.keys)
      child.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    for (final ChildType child in _childToSlot.keys)
      child.detach();
  }

  int get childCount => _slotToChild.length;

  bool hasChild(dynamic slot) => _slotToChild[slot] != null;

  ChildType getChild(dynamic slot) => _slotToChild[slot]!;
}

mixin CustomRenderBoxDefaultsMixin implements RenderBox, CustomRenderObjectMixin<RenderBox> {

  Size? layoutChild(dynamic slot, BoxConstraints constraints, { bool parentUsesSize = false }) {
    assert(hasChild(slot));
    final RenderBox child = getChild(slot);
    child.layout(constraints, parentUsesSize: parentUsesSize);
    return parentUsesSize ? child.size : null;
  }

  void positionChild(dynamic slot, Offset offset) {
    assert(hasChild(slot));
    final RenderBox child = getChild(slot);
    final BoxParentData parentData = child.parentData as BoxParentData;
    parentData.offset = offset;
  }

  bool hitTestChild(dynamic slot, BoxHitTestResult result, { required Offset position }) {
    assert(hasChild(slot));
    final RenderBox child = getChild(slot);
    final BoxParentData parentData = child.parentData as BoxParentData;
    return child.hitTest(result, position: position - parentData.offset);
  }

  void paintChild(dynamic slot, PaintingContext context, Offset offset) {
    assert(hasChild(slot));
    final RenderBox child = getChild(slot);
    final BoxParentData parentData = child.parentData as BoxParentData;
    context.paintChild(child, offset + parentData.offset);
  }

  @protected
  List<dynamic>? get hitTestOrdering => null;

  @protected
  List<dynamic>? get paintOrdering => hitTestOrdering?.reversed.toList();

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    final slots = hitTestOrdering;
    if (slots != null) {
      for (final slot in slots) {
        if (hasChild(slot) && hitTestChild(slot, result, position: position))
          return true;
      }
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final slots = paintOrdering;
    if (slots != null) {
      for (final slot in slots) {
        if (hasChild(slot)) {
          paintChild(slot, context, offset);
        }
      }
    }
  }
}
