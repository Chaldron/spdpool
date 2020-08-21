import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';

/// The view model for the players screen.
@immutable
class PlayersModel {
  final List<Player> players;
  final void Function(Player player) createPlayer;

  const PlayersModel({this.players, this.createPlayer});
}

/// A single Player's card display.
class PlayerCard extends StatelessWidget {
  final Player player;

  PlayerCard(this.player);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(fontSize: 30.0),
                      ),
                      Text(player.ranking.toString(),
                          style: TextStyle(fontSize: 30.0))
                    ],
                  )))),
    );
  }
}

class NewPlayerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [FlatButton(onPressed: () => Navigator.pop(context),)],
      )
    );
  }

}

/// The players screen.
class PlayersDisplay extends StatelessWidget {
  PlayersDisplay();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PlayersModel>(
        converter: (store) => PlayersModel(
            players: store.state.players,
            createPlayer: (player) =>
                store.dispatch(RegisterPlayerAction(player))),
        builder: (context, model) {
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(child: NewPlayerDialog());
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.redAccent,
              ),
              body: ListView(
                  scrollDirection: Axis.vertical,
                  children: model.players
                      .map((player) => PlayerCard(player))
                      .toList()));
        });
  }
}
