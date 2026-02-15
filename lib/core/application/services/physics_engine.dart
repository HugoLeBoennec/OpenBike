import 'dart:math';

import '../../domain/value_objects/value_objects.dart';

/// Cycling physics model based on Martin et al. (1998).
///
/// Total resistive force:
///   F_gravity = m·g·sin(atan(grade))
///   F_rolling = m·g·cos(atan(grade))·Crr
///   F_aero    = 0.5·ρ·CdA·(v + v_wind)²
///
/// Power:
///   P = v·(F_gravity + F_rolling + F_aero) / η
class CyclingPhysicsEngine {
  static const double _g = 9.81;
  static const double _rho = 1.225; // air density kg/m³
  static const double _eta = 0.975; // drivetrain efficiency (2.5% loss)

  /// Calculates the power required to sustain [speed] on [grade].
  Watts calculateRequiredPower({
    required Speed speed,
    required Grade grade,
    double mass = 80,
    double crr = 0.004,
    double cda = 0.32,
    double windSpeed = 0,
  }) {
    final v = speed.mps;
    if (v <= 0) return Watts.zero;

    final theta = atan(grade.ratio);
    final fGravity = mass * _g * sin(theta);
    final fRolling = mass * _g * cos(theta) * crr;
    final vEff = v + windSpeed;
    final fAero = 0.5 * _rho * cda * vEff * vEff;
    final power = v * (fGravity + fRolling + fAero) / _eta;
    return Watts(max(0, power));
  }

  /// Calculates the speed achievable at [power] on [grade] using
  /// Newton-Raphson iteration.
  ///
  /// f(v) = v·(F_gravity + F_rolling + 0.5·ρ·CdA·(v+w)²) / η - P = 0
  Speed calculateSpeed({
    required Watts power,
    required Grade grade,
    double mass = 80,
    double crr = 0.004,
    double cda = 0.32,
    double windSpeed = 0,
  }) {
    if (power.value <= 0) return Speed.zero;

    final theta = atan(grade.ratio);
    final fGravity = mass * _g * sin(theta);
    final fRolling = mass * _g * cos(theta) * crr;
    final p = power.value;

    // f(v) = v * (fGravity + fRolling + 0.5*rho*cda*(v+w)^2) / eta - p
    // f'(v) = (fGravity + fRolling + 0.5*rho*cda*(v+w)^2) / eta
    //       + v * (0.5*rho*cda*2*(v+w)) / eta
    //       = (fGravity + fRolling + 0.5*rho*cda*(v+w)^2 + rho*cda*v*(v+w)) / eta

    // Initial guess: 5 m/s flat, or estimate coasting speed for descents.
    double v = 5.0;
    if (fGravity < 0) {
      // Downhill: gravity assists. Estimate coasting speed from drag balance.
      final coastForce = -(fGravity + fRolling);
      if (coastForce > 0) {
        v = sqrt(coastForce / (0.5 * _rho * cda));
      }
    }

    for (var i = 0; i < 50; i++) {
      final vw = v + windSpeed;
      final fAero = 0.5 * _rho * cda * vw * vw;
      final totalForce = fGravity + fRolling + fAero;
      final fv = v * totalForce / _eta - p;
      final fpv = (totalForce + _rho * cda * v * vw) / _eta;

      if (fpv.abs() < 1e-12) break; // avoid division by zero
      final dv = fv / fpv;
      v -= dv;
      if (v < 0.01) v = 0.01; // keep positive
      if (dv.abs() < 0.001) break; // converged
    }

    // Convert m/s → km/h, clamp to reasonable range.
    return Speed((v.clamp(0, 40) * 3.6));
  }

  /// Convenience wrapper — delegates to [calculateSpeed].
  Speed estimateSpeed({
    required Watts power,
    required Grade grade,
    double weight = 80,
    double crr = 0.004,
    double cda = 0.32,
  }) {
    return calculateSpeed(
      power: power,
      grade: grade,
      mass: weight,
      crr: crr,
      cda: cda,
    );
  }

  /// Convenience wrapper — delegates to [calculateRequiredPower].
  Watts estimatePower({
    required Speed speed,
    required Grade grade,
    double weight = 80,
    double crr = 0.004,
    double cda = 0.32,
  }) {
    return calculateRequiredPower(
      speed: speed,
      grade: grade,
      mass: weight,
      crr: crr,
      cda: cda,
    );
  }
}
