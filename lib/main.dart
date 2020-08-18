import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:spd_pool/players.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/middleware.dart';
import 'package:spd_pool/state/reducers.dart';
import 'package:spd_pool/state/state.dart';

const APP_TITLE = 'SPD Pool';

void main() {
  runApp(new App());
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

@immutable
class NavigationPage {
  final String title;
  final Icon icon;
  final Widget body;

  const NavigationPage({this.title, this.icon, this.body});
}

class _AppState extends State<App> {
  final store = Store<AppState>(rootReducer,
      initialState: AppState(), middleware: rootMiddleware());

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
        store: store,
        child: MaterialApp(
            title: APP_TITLE,
            theme: ThemeData.dark(),
            home: new StoreBuilder(
                onInit: (store) => store.dispatch(RequestSubscriptionsAction()),
                onDispose: (store) =>
                    store.dispatch(CancelSubscriptionsAction()),
                builder: (context, Store<AppState> store) {
                  return Home(title: APP_TITLE, children: [
                    NavigationPage(
                        title: 'Play',
                        icon: Icon(Icons.pool),
                        body: PlayersDisplay()),
                    NavigationPage(
                        title: 'Matches',
                        icon: Icon(Icons.history),
                        body: PlayersDisplay()),
                    NavigationPage(
                        title: 'Players',
                        icon: Icon(Icons.people),
                        body: PlayersDisplay())
                  ]);
                })));
  }
}

class Home extends StatefulWidget {
  final String title;
  final List<NavigationPage> children;

  const Home({Key key, this.title, this.children}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState(title: title, children: children);
  }
}

class _HomeState extends State<Home> {
  final String title;
  final List<NavigationPage> children;
  int _currentPageIndex = 0;

  _HomeState({this.children, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
          padding: EdgeInsets.all(8.0),
          child: children[_currentPageIndex].body),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          onTap: (int index) => setState(() => _currentPageIndex = index),
          items: children.map((child) {
            var bottomNavigationBarItem = BottomNavigationBarItem(
                title: Text(child.title), icon: child.icon);
            return bottomNavigationBarItem;
          }).toList()),
    );
  }
}
