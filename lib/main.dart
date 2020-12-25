import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

import 'package:spd_pool/play.dart';
import 'package:spd_pool/players.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';

/// The redux store.
Store<AppState> store;

void main() {
  // Initialize the redux store.
  store = Store<AppState>(initialState: const AppState());
  // Start the ap.
  runApp(App());
}

/// Represents a single navigation page for our tabbed bottom-bar layout.
/// Contains a title, icon, and associated widget.
@immutable
class NavigationPage {
  /// The title of this page.
  final String title;

  /// This page's bottom-bar icon.
  final Icon icon;

  /// The actual contents of this page.
  final Widget body;

  const NavigationPage({this.title, this.icon, this.body});
}

/// Represents the state of the main app body.
/// Keeps track of the currently user-selected page,
/// and switches between them on tap.
class _HomeState extends State<Home> {
  /// Title of the main app body
  final String title;

  /// Child navigation pages
  final List<NavigationPage> children;

  /// The currently selected page.
  int _currentPageIndex = 0;

  _HomeState({this.children, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
          padding: const EdgeInsets.all(8.0),
          // Show the currently selected child
          child: children[_currentPageIndex].body),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          // Update the current index on tap
          onTap: (int index) => setState(() => _currentPageIndex = index),
          // Show icons for each of the children
          items: children.map((child) {
            final bottomNavigationBarItem =
                BottomNavigationBarItem(label: child.title, icon: child.icon);
            return bottomNavigationBarItem;
          }).toList()),
    );
  }
}

/// A main app body widget.
/// Retains a set of children pages (widgets)
class Home extends StatefulWidget {
  /// Title of the main app body
  final String title;

  /// Child navigation pages
  final List<NavigationPage> children;

  const Home({Key key, this.title, this.children}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState(title: title, children: children);
  }
}

/// Dummy state for our app to use the StoreConnector.
class _AppState {}

/// Holds the overall state of the application.
/// Connects the app to the Redux store.
class App extends StatelessWidget {
  static const APP_TITLE = 'SPD Pool';
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: APP_TITLE,
        theme: ThemeData.dark(),
        // Have to use StoreConnector here since async_redux doesn't provide
        // a StoreBuilder which simply refreshes on the entire store.
        home: StoreConnector<AppState, _AppState>(
          // Setup subscriptions to Firebase on initialization
          onInit: (store) => store.dispatch(RequestSubscriptionsAction()),
          // Cancel subscriptions to Firebase when closing
          onDispose: (store) => store.dispatch(CancelSubscriptionsAction()),
          // Dummy state
          converter: (store) => _AppState(),
          builder: (context, _) {
            return Home(
              title: APP_TITLE,
              children: [
                // New match screen
                NavigationPage(
                  title: 'Play',
                  icon: const Icon(Icons.pool),
                  body: PlayDisplay(),
                ),
                // Match history
                NavigationPage(
                  title: 'Matches',
                  icon: const Icon(Icons.history),
                  body: PlayersDisplay(),
                ),
                // Players
                NavigationPage(
                  title: 'Players',
                  icon: const Icon(Icons.people),
                  body: PlayersDisplay(),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
