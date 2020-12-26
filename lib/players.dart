/// players.dart
/// This file contains the "Players" screen, where users
/// can add, update, and view the different players.

import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:spd_pool/constants.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';

class _PlayerCard extends StatelessWidget {
  /// The player this card is displaying.
  final Player player;

  /// This player's relative rank.
  final int relativeRank;

  _PlayerCard({this.player, this.relativeRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Minimum card height: 100px
      constraints: const BoxConstraints(minHeight: 100),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: ILLINOIS_GREY,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          // Wrap in material to use InkWell effects
          child: Material(
            // Don't show any color overlays
            type: MaterialType.transparency,
            child: InkWell(
              // Pass onTap functionality from state
              child: Padding(
                // Pad text within the card
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Relative ranking
                    Expanded(
                      flex: 2,
                      child: AutoSizeText(
                        relativeRank.toString(),
                        style: const TextStyle(fontSize: 30.0),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        minFontSize: 15,
                        maxFontSize: 30,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: AutoSizeText(
                        player.name,
                        style: const TextStyle(fontSize: 30.0),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 15,
                        maxFontSize: 30,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Actual ranking
                    Expanded(
                      flex: 2,
                      child: AutoSizeText(
                        player.rating.toInt().toString(),
                        style: const TextStyle(fontSize: 30.0),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        minFontSize: 15,
                        maxFontSize: 30,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _NewPlayerDialogModel {
  final void Function(Player player) createPlayer;

  const _NewPlayerDialogModel({this.createPlayer});
}

/// The new player full-screen dialog state.
class _NewPlayerDialogState extends State<_NewPlayerDialog> {
  /// A unique key for the form contained in this widget.
  final formKey = GlobalKey<FormState>();

  /// The currently entered new player name.
  String currentNewPlayerName = '';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _NewPlayerDialogModel>(
      converter: (store) => _NewPlayerDialogModel(
        createPlayer: (player) => {
          store.dispatch(RegisterPlayerAction(player: player)),
        },
      ),
      builder: (context, model) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Player'),
            actions: [
              FlatButton(
                onPressed: () {
                  // Create a player if the form state is valid
                  if (formKey.currentState.validate()) {
                    print(currentNewPlayerName);
                    model.createPlayer(Player(name: currentNewPlayerName));
                    // At the end, pop the dialog
                    Navigator.pop(context);
                  }
                },
                child:
                    Text('Save', style: Theme.of(context).textTheme.subtitle1),
              )
            ],
          ),
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // Name field
                    TextFormField(
                        decoration: const InputDecoration(hintText: 'Name'),
                        // Cannot be empty
                        validator: (value) {
                          return value.isEmpty ? 'Name cannot be empty.' : null;
                        },
                        onChanged: (String value) {
                          currentNewPlayerName = value;
                        })
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The new player full screen dialog widget.
class _NewPlayerDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewPlayerDialogState();
  }
}

/// The view model for the players widget.
@immutable
class _PlayersModel {
  /// The list of players we're showing.
  final List<Player> players;
  final void Function(Player player) createPlayer;

  const _PlayersModel({this.players, this.createPlayer});
}

/// The players screen.
class PlayersDisplay extends StatelessWidget {
  PlayersDisplay();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PlayersModel>(
      converter: (store) => _PlayersModel(
        players: store.state.playerState.players,
        createPlayer: (player) => store.dispatch(
          RegisterPlayerAction(player: player),
        ),
      ),
      builder: (context, model) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Push the new player dialog screen as a full screen dialog
              Navigator.of(context).push(
                MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return _NewPlayerDialog();
                    },
                    fullscreenDialog: true),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: ListView(
            scrollDirection: Axis.vertical,
            children: model.players
                .map(
                  (player) => _PlayerCard(
                      player: player,
                      relativeRank: model.players.indexOf(player) + 1),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
