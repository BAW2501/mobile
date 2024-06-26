import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/clock/clock_controller.dart';
import 'package:lichess_mobile/src/styles/lichess_colors.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/widgets/countdown_clock.dart';

const _darkClockStyle = ClockStyle(
  textColor: Colors.black87,
  activeTextColor: Colors.white,
  emergencyTextColor: Colors.white,
  backgroundColor: Colors.transparent,
  activeBackgroundColor: Colors.transparent,
  emergencyBackgroundColor: Color(0xFF673431),
);

const _lightClockStyle = ClockStyle(
  textColor: Colors.black87,
  activeTextColor: Colors.white,
  emergencyTextColor: Colors.black,
  backgroundColor: Colors.transparent,
  activeBackgroundColor: Colors.transparent,
  emergencyBackgroundColor: Color(0xFFF2CCCC),
);

class ClockTile extends ConsumerWidget {
  final ClockPlayerType playerType;
  final ClockState clockState;

  const ClockTile({
    required this.playerType,
    required this.clockState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color getBackgroundColor() {
      if (clockState.isLoser(playerType)) {
        return LichessColors.red;
      } else if (clockState.isPlayersTurn(playerType) &&
          clockState.currentPlayer != null) {
        return LichessColors.brag;
      } else {
        return Colors.grey;
      }
    }

    return PopScope(
      canPop: false,
      child: RotatedBox(
        quarterTurns: playerType == ClockPlayerType.top ? 2 : 0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: clockState.paused ? 0.7 : 1,
              child: Material(
                color: getBackgroundColor(),
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: clockState.isPlayersMoveAllowed(playerType)
                      ? () {
                          ref
                              .read(clockControllerProvider.notifier)
                              .onTap(playerType);
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: FittedBox(
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: CountdownClock(
                          key: Key('${clockState.id}-$playerType'),
                          lightColorStyle: _lightClockStyle,
                          darkColorStyle: _darkClockStyle,
                          duration: clockState.getDuration(playerType),
                          active: clockState.isActivePlayer(playerType),
                          onFlag: () {
                            ref
                                .read(clockControllerProvider.notifier)
                                .setLoser(playerType);
                          },
                          onStop: (remaining) {
                            ref
                                .read(clockControllerProvider.notifier)
                                .updateDuration(playerType, remaining);
                          },
                        ),
                        secondChild: const Icon(Icons.flag),
                        crossFadeState: clockState.isLoser(playerType)
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: Text(
                '${context.l10n.stormMoves}: ${clockState.getMovesCount(playerType)}',
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
