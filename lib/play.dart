import 'package:async_redux/async_redux.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:spd_pool/constants.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';
import 'package:spd_pool/utils/elo.dart';

import 'main.dart';

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

    // The list of attributes to display
    var attributes = [
      // Player name
      Expanded(
        flex: 4,
        child: AutoSizeText(
          player.name,
          style: TextStyle(fontSize: 30.0, color: textColor),
          textAlign: TextAlign.center,
          maxLines: 1,
          minFontSize: 15,
          maxFontSize: 30,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    // Add relative/actual rank if the screen is big enough
    if (largeScreen) {
      attributes = [
        // Relative ranking
        Expanded(
          flex: 2,
          child: AutoSizeText(
            relativeRank.toString(),
            style: TextStyle(fontSize: 30.0, color: textColor),
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 15,
            maxFontSize: 30,
          ),
        ),
        ...attributes,
        // Actual ranking
        Expanded(
          flex: 2,
          child: AutoSizeText(
            player.rating.toInt().toString(),
            style: TextStyle(fontSize: 30.0, color: textColor),
            textAlign: TextAlign.right,
            maxLines: 1,
            minFontSize: 15,
            maxFontSize: 30,
          ),
        )
      ];
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: ILLINOIS_GREY,
          shape: RoundedRectangleBorder(
            // Show white border when player is selected
            side: isSelected
                ? const BorderSide(color: Colors.white, width: 6.00)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Padding(
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
                store.dispatch(AddMatchAction(
                  player1: players[selectedIndexLeft],
                  player2: players[selectedIndexRight],
                  winner: MatchWinner.Player1,
                ));
              }
            : null;

    /// Compute the win chance for both of the selected players so we can show the bars
    final leftWinChance = selectedIndexLeft >= 0 && selectedIndexRight >= 0
        ? winChanceForPlayer(
            players[selectedIndexLeft], players[selectedIndexRight])
        : 0.5;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
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
          // Chance bar separator
          Container(
            height: 40,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 8, color: Colors.white),
              ),
            ),
            // Chance bars
            child: Row(
              children: [
                // Left
                Expanded(
                  flex: (leftWinChance * 100).toInt(),
                  child: Stack(
                    children: [
                      Container(color: ILLINOIS_ORANGE),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${(100 * leftWinChance).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right
                Expanded(
                  flex: (100 - 100 * leftWinChance).toInt(),
                  child: Stack(
                    children: [
                      Container(color: ILLINOIS_BLUE),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${(100 * (1 - leftWinChance)).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
            ),
          ),
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
      converter: (store) =>
          _PlayModel(players: store.state.playerState.players),
      builder: (context, model) {
        return _PlayersListDisplay(
          players: model.players,
          key: ObjectKey(model.players),
        );
      },
    );
  }
}
