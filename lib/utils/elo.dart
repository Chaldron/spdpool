import 'dart:math';

import 'package:spd_pool/state/state.dart';

const ELO_STARTING_RATING = 1200.0;

/// Computes the winning probability for `player` against `other`.
double winChanceForPlayer(Player player, Player other) {
  return _winChance(player.rating, other.rating);
}

/// Computes the winning probability for a player with `rating` against `other`.
double _winChance(double rating, double other) {
  return 1.0 / (1.0 + pow(10, ((other - rating) / 400)));
}

/// Computes the elo update coefficient (`k`) for a given `player`.
double _eloUpdateCoefficientForRating(double rating) {
  return 32;
}

List<double> computeNewPlayerRankings(
    double ratingP1, double ratingP2, bool winP1) {
  // Compute chance for player 1 and 2 to win.
  final winProbP1 = _winChance(ratingP1, ratingP2);
  final winProbP2 = _winChance(ratingP2, ratingP1);

  // Compute the player score (1 for win, 0 for loss).
  final scoreP1 = winP1 ? 1 : 0;
  final scoreP2 = !winP1 ? 1 : 0;

  // Compute the new ratings.
  // The new score is a multiple of the win probability of the *other* player
  // subtracted from our actual score.
  ratingP1 = ratingP1 +
      _eloUpdateCoefficientForRating(ratingP1) * (scoreP1 - winProbP2);
  ratingP2 = ratingP2 +
      _eloUpdateCoefficientForRating(ratingP1) * (scoreP2 - winProbP1);

  return [ratingP1, ratingP2];
}

/// Given a list of players and matches, returns a new list of players with updating rankings.
Map<String, double> computePlayerRankings(
    {List<Player> players, List<Match> matches}) {
  // Initialize a map of ratings to the starting rating.
  final playerMap = <String, double>{};
  for (final p in players) {
    playerMap.putIfAbsent(p.name, () => ELO_STARTING_RATING);
  }

  for (final m in matches) {
    // Get existing ratings.
    var ratingP1 = playerMap[m.player1.name];
    var ratingP2 = playerMap[m.player2.name];

    // Compute chance for player 1 and 2 to win.
    final winProbP1 = _winChance(ratingP1, ratingP2);
    final winProbP2 = _winChance(ratingP2, ratingP1);

    // Compute the player score (1 for win, 0 for loss).
    final scoreP1 = m.winner == MatchWinner.Player1 ? 1 : 0;
    final scoreP2 = m.winner == MatchWinner.Player2 ? 1 : 0;

    // Update each player's ranking.
    // The new score is a multiple of the win probability of the *other* player
    // subtracted from our actual score.
    ratingP1 = ratingP1 +
        _eloUpdateCoefficientForRating(ratingP1) * (scoreP1 - winProbP2);
    ratingP2 = ratingP2 +
        _eloUpdateCoefficientForRating(ratingP2) * (scoreP2 - winProbP1);

    // Insert new rating back into the map.
    playerMap[m.player1.name] = ratingP1;
    playerMap[m.player2.name] = ratingP2;
  }

  return playerMap;
}
