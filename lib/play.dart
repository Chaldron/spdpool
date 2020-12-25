import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:spd_pool/constants.dart';
import 'package:spd_pool/state/state.dart';

/// A single Player's card display.
class _PlayerCard extends StatelessWidget {
  /// The player this card is displaying.
  final Player player;

  /// This player's relative rank.
  final int relativeRank;

  /// Whether or not this player is currently selected.
  final bool isSelected;

  /// The on tap action for this player
  /// If null, this player cannot be selected.
  final void Function() onTap;

  _PlayerCard({this.player, this.relativeRank, this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use a grey text color when this player cannot be selected
    final textColor = onTap != null ? Colors.white : Colors.grey;
    // Show all attributes on large screens, and only name on small ones
    // This should be updated at some point to be less hacky
    final queryData = MediaQuery.of(context);
    final largeScreen = queryData.size.width > 800;
    // The list of attributes
    final attributes = [
      // Relative rank
      largeScreen
          ? Text(
              relativeRank.toString(),
              style: TextStyle(fontSize: 30.0, color: textColor),
            )
          : const Spacer(),
      // Player name
      Text(
        player.name,
        style: TextStyle(fontSize: 30.0, color: textColor),
      ),
      // Actual rank
      largeScreen
          ? Text(
              player.ranking.toInt().toString(),
              style: TextStyle(fontSize: 30.0, color: textColor),
            )
          : const Spacer()
    ];

    return Container(
      height: 85,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          // Grey card
          color: ILLINOIS_GREY,
          shape: RoundedRectangleBorder(
            // White border when this player is selected
            side: isSelected
                ? const BorderSide(color: Colors.white, width: 6.00)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          // Wrap in material to use InkWell effects
          child: Material(
            // Don't show any color overlays
            type: MaterialType.transparency,
            child: InkWell(
              // Pass onTap functionality from state
              onTap: onTap,
              child: Padding(
                // Pad text within the card
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: attributes,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The player list state.
class _PlayersListDisplayState extends State<_PlayersListDisplay> {
  /// The players we're showing.
  final List<Player> players;

  /// The currently selected indices on each side of the selection screen;
  /// Defaults to -1 so no one is selected from the start.
  int selectedIndexLeft = -1, selectedIndexRight = -1;

  _PlayersListDisplayState({this.players});

  /// Returns a builder for a listview item, given which side that list is on.
  /// This lets us maintain state across both sides of the list, since we need to
  /// keep track of which card is selected on both sides.
  Widget Function(BuildContext, int) listItemBuilderBuilder(bool left) {
    return (BuildContext context, int index) {
      // We should disable a player card if the corresponding card on the other side is selected.
      final disabled = !((left && index != selectedIndexRight) ||
          (!left && index != selectedIndexLeft));
      return _PlayerCard(
        player: players[index],
        // Player is sorted, so rank = index + 1.
        relativeRank: index + 1,
        // Whether or not this player is selected.
        isSelected: index == (left ? selectedIndexLeft : selectedIndexRight),
        // On tap action (update selected index on the corresponding side),
        // only if we're not disabled.
        onTap: !disabled
            ? () {
                setState(() {
                  // Update the corresponding index.
                  // Allow unselection of player cards.
                  if (left) {
                    if (selectedIndexLeft == index) {
                      selectedIndexLeft = -1;
                    } else {
                      selectedIndexLeft = index;
                    }
                  } else {
                    if (selectedIndexRight == index) {
                      selectedIndexRight = -1;
                    } else {
                      selectedIndexRight = index;
                    }
                  }
                });
              }
            : null,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    /// The onTap handler for the start button.
    /// Should be null if two valid players haven't been selected.
    final Function onStartPressed =
        selectedIndexLeft >= 0 && selectedIndexRight >= 0
            ? () {
                print('start');
              }
            : null;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            // The row of list views
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Left player list view
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemBuilder: listItemBuilderBuilder(true),
                      itemCount: players.length,
                    ),
                    color: ILLINOIS_ORANGE,
                  ),
                ),
                // Right player list view
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemBuilder: listItemBuilderBuilder(false),
                      itemCount: players.length,
                    ),
                    color: ILLINOIS_BLUE,
                  ),
                ),
              ],
            ),
          ),
          // Start button
          Container(
              height: 70,
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: onStartPressed,
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 22.0),
                ),
              )),
        ],
      ),
    );
  }
}

/// The player list widget.
class _PlayersListDisplay extends StatefulWidget {
  final List<Player> players;

  _PlayersListDisplay({this.players, Key key}) : super(key: key);
  @override
  State<_PlayersListDisplay> createState() {
    return _PlayersListDisplayState(players: players);
  }
}

/// The view model for the play screen.
@immutable
class _PlayModel {
  /// The players we're showing.
  final List<Player> players;

  _PlayModel({this.players});
}

/// The play screen.
class PlayDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('building');
    return StoreConnector<AppState, _PlayModel>(
      converter: (store) => _PlayModel(players: store.state.players),
      builder: (context, model) {
        return _PlayersListDisplay(
          players: model.players,
          key: ObjectKey(model.players),
        );
      },
    );
  }
}
