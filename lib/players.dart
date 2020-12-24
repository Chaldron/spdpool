/**
 * players.dart
 * 
 * This file contains the "Players" screen, where users 
 * can add, update, and view the different players.
 */

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:spd_pool/constants.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';

/// A single Player's card display.
class _PlayerCard extends StatelessWidget {
  /// The player this card is displaying.
  final Player _player;

  /// This player's relative rank.
  final int _relativeRank;

  _PlayerCard(this._player, this._relativeRank);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Card(
          color: ILLINOIS_GREY,
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Relative rank
                Text(
                  _relativeRank.toString(),
                  style: TextStyle(fontSize: 30.0),
                ),
                // Player name
                Text(
                  _player.name,
                  style: TextStyle(fontSize: 30.0),
                ),
                // Actual ranking
                Text(
                  _player.ranking.toInt().toString(),
                  style: TextStyle(fontSize: 30.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The new player full-screen dialog.
class _NewPlayerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: "Name"),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}

/// The view model for the players screen.
@immutable
class _PlayersModel {
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
              players: store.state.players,
              createPlayer: (player) => store.dispatch(
                RegisterPlayerAction(player),
              ),
            ),
        builder: (context, model) {
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(context: context, child: _NewPlayerDialog());
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.redAccent,
              ),
              body: ListView(
                  scrollDirection: Axis.vertical,
                  children: model.players
                      .map((player) => _PlayerCard(
                          player, model.players.indexOf(player) + 1))
                      .toList()));
        });
  }
}
