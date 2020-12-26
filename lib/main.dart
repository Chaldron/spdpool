import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:spd_pool/matches.dart';

import 'package:spd_pool/play.dart';
import 'package:spd_pool/players.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';

/// The redux store.
Store<AppState> store;

void main() {
  // Initialize the redux store.
  store = Store<AppState>(initialState: const AppState());
  // Start the app.
  runApp(App());
}

/// Represents a single navigation page for our tabbed bottom-bar layout.
/// Contains a title, icon, and associated widget.
@immutable
class _NavigationPage {
  /// The title of this page.
  final String title;

  /// This page's bottom-bar icon.
  final Icon icon;

  /// The actual contents of this page.
  final Widget body;

  const _NavigationPage({this.title, this.icon, this.body});
}

/// Represents the state of the main app body.
/// Keeps track of the currently user-selected page,
/// and switches between them on tap.
class _HomeState extends State<Home> {
  /// Title of the main app body
  final String title;

  /// Child navigation pages
  final List<_NavigationPage> children;

  /// The currently selected page.
  int currentPageIndex = 0;

  _HomeState({this.children, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
          padding: const EdgeInsets.all(8.0),
          child: children[currentPageIndex].body),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        // Update the current index on tap
        onTap: (int index) => setState(() => currentPageIndex = index),
        items: children
            .map((child) =>
                BottomNavigationBarItem(label: child.title, icon: child.icon))
            .toList(),
      ),
    );
  }
}

/// A main app body widget.
/// Retains a set of children navigation pages.
class Home extends StatefulWidget {
  /// Title of the main app body
  final String title;

  /// Child navigation pages
  final List<_NavigationPage> children;

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
                _NavigationPage(
                  title: 'Play',
                  icon: const Icon(Icons.pool),
                  body: PlayDisplay(),
                ),
                // Match history
                _NavigationPage(
                  title: 'Matches',
                  icon: const Icon(Icons.history),
                  body: MatchesDisplay(),
                ),
                // Players
                _NavigationPage(
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
