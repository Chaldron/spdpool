import 'package:async_redux/async_redux.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:spd_pool/constants.dart';
import 'package:spd_pool/state/state.dart';

class _MatchCard extends StatelessWidget {
  /// The match this card is displaying.
  final Match match;

  /// The previous match to this one.
  final Match previousMatch;

  _MatchCard({this.match, this.previousMatch});

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
                        match.player1.name + " - " + match.eloDelta1.toString(),
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
                        match.player2.name + " - " + match.eloDelta2.toString(),
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
                        match.winner.toString(),
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

/// The view model for the players widget.
@immutable
class _MatchesModel {
  /// The list of matches we're showing.
  final List<Match> matches;

  const _MatchesModel({this.matches});
}

/// The players screen.
class MatchesDisplay extends StatelessWidget {
  MatchesDisplay();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _MatchesModel>(
      converter: (store) => _MatchesModel(
        matches: store.state.matchesState.matches.reversed.toList(),
      ),
      builder: (context, model) {
        return Scaffold(
          body: ListView(
            scrollDirection: Axis.vertical,
            children: model.matches
                .asMap()
                .entries
                .map(
                  (entry) => _MatchCard(
                    match: entry.value,
                    previousMatch: entry.key > 0
                        ? model.matches[entry.key - 1]
                        : entry.value,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
