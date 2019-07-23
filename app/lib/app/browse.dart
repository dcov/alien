import 'package:flutter/material.dart';

import 'base.dart';
import 'defaults.dart';
import 'feeds.dart';
import 'route.dart';
import 'scrollable.dart';
import 'subscriptions.dart';

class BrowseModelSideEffects {

  const BrowseModelSideEffects();

  DefaultsModel createDefaultsModel() => DefaultsModel();

  FeedsModel createFeedsModel(bool isSignedIn) => FeedsModel(isSignedIn);

  SubscriptionsModel createSubscriptionsModel() => SubscriptionsModel();
}

class BrowseModel extends RouteModel with ScrollableModelMixin {

  BrowseModel(bool isSignedIn, [ BrowseModelSideEffects sideEffects = const BrowseModelSideEffects() ])
    : feeds = sideEffects.createFeedsModel(isSignedIn),
      defaults = !isSignedIn ? Optional.of(sideEffects.createDefaultsModel())
                             : Optional.absent(),
      subscriptions = isSignedIn ? Optional.of(sideEffects.createSubscriptionsModel())
                                 : Optional.absent();

  final Optional<DefaultsModel> defaults;

  final FeedsModel feeds;

  final Optional<SubscriptionsModel> subscriptions;

  @override
  void didPush() {
    defaults.ifPresent((model) => model.refresh());
    subscriptions.ifPresent((model) => model.refresh());
  }

  @override
  void didPop() {
    feeds.dispose();
    subscriptions.ifPresent((model) => model.dispose());
    defaults.ifPresent((model) => model.dispose());
  }
}

class BrowsePageRoute<T> extends ModelPageRoute<T, BrowseModel> {

  BrowsePageRoute({ RouteSettings settings, @required BrowseModel model})
    : super(settings: settings, model: model);

  @override
  Widget build(BuildContext context) {
    return _BrowsePage(model: model);
  }

  @override
  Widget buildBottomHandle(BuildContext context) {
    return _BrowsePageBottomHandle(model: model);
  }
}

class _BrowsePage extends View<BrowseModel> {

  _BrowsePage({ Key key, @required BrowseModel model })
    : super(key: key, model: model);

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends ViewState<BrowseModel, _BrowsePage> with ScrollableStateMixin {

  @override
  List<Widget> buildSlivers(BuildContext context) {
    final List<Widget> slivers = <Widget>[
      SliverPadding(
        padding: EdgeInsets.only(top: 92.0),
        sliver: FeedsSliver(model: model.feeds),
      ),
    ];
    model.defaults.ifPresent((DefaultsModel model) {
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(bottom: 24.0),
          sliver: DefaultsSliver(model: model),
        )
      );
    });
    model.subscriptions.ifPresent((SubscriptionsModel model) {
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(bottom: 24.0),
          sliver: SubscriptionsSliver(model: model),
        )
      );
    });
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        buildScrollView(context),
        Padding(
          padding: Insets.halfAll + MediaQuery.of(context).padding,
          child: Material(
            elevation: 1.0,
            borderRadius: BorderRadius.circular(20.0),
            clipBehavior: Clip.antiAlias,
            type: MaterialType.card,
            color: Theme.of(context).backgroundColor,
            child: SizedBox(
              height: 40.0,
              child: NavigationToolbar(
                middle: Body2Text(
                  'Browse',
                )
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _BrowsePageBottomHandle extends StatelessWidget {

  _BrowsePageBottomHandle({
    Key key,
    @required this.model
  }) : super(key: key);

  final BrowseModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          onPressed: () { },
          icon: Icon(Icons.more_vert),
        )
      ],
    );
  }
}