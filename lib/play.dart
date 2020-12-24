import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:spd_pool/state/actions.dart';
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
  void Function() onTap;

  _PlayerCard({this.player, this.relativeRank, this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Card(
          color: Color(0xFF5E6669),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
              width: isSelected ? 8.00 : 0.01,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Relative rank
                    Text(
                      relativeRank.toString(),
                      style: TextStyle(
                          fontSize: 30.0,
                          color: onTap != null ? Colors.white : Colors.grey),
                    ),
                    // Player name
                    Text(
                      player.name,
                      style: TextStyle(
                          fontSize: 30.0,
                          color: onTap != null ? Colors.white : Colors.grey),
                    ),
                    // Actual ranking
                    Text(player.ranking.toInt().toString(),
                        style: TextStyle(
                            fontSize: 30.0,
                            color: onTap != null ? Colors.white : Colors.grey))
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

/// The view model for the matches screen.
@immutable
class PlayModel {
  final List<Player> players;

  const PlayModel({this.players});
}

class _PlayersListDisplayState extends State<PlayersListDisplay> {
  final List<Player> _players;
  int _selectedIndexLeft = 0, _selectedIndexRight = 0;

  _PlayersListDisplayState(this._players);

  Widget Function(BuildContext, int) _listItemBuilderBuilder(bool left) {
    return (BuildContext context, int index) {
      bool disabled = !((left && index != _selectedIndexRight) ||
          (!left && index != _selectedIndexLeft));
      return _PlayerCard(
        player: _players[index],
        relativeRank: index + 1,
        isSelected: index == (left ? _selectedIndexLeft : _selectedIndexRight),
        onTap: !disabled
            ? () {
                setState(() {
                  if (left)
                    _selectedIndexLeft = index;
                  else
                    _selectedIndexRight = index;
                });
              }
            : null,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            child: ListView.builder(
              itemBuilder: _listItemBuilderBuilder(true),
              itemCount: _players.length,
            ),
            color: Color(0xFFE84A27),
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemBuilder: _listItemBuilderBuilder(false),
              itemCount: _players.length,
            ),
            color: Color(0xFF13294B),
          ),
        )
      ],
    );
  }
}

class PlayersListDisplay extends StatefulWidget {
  final List<Player> _players;

  PlayersListDisplay(this._players);
  @override
  State<StatefulWidget> createState() {
    return _PlayersListDisplayState(_players);
  }
}

class PlayDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PlayModel>(
      converter: (store) => PlayModel(players: store.state.players),
      builder: (context, model) {
        return PlayersListDisplay(model.players);
      },
    );
  }
}
