import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/services/user_analytics_service.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

class AmplitudeTestScreen extends StatefulWidget {
  const AmplitudeTestScreen({super.key});

  @override
  State<AmplitudeTestScreen> createState() => _AmplitudeTestScreenState();
}

class _AmplitudeTestScreenState extends State<AmplitudeTestScreen> {
  bool _isSending = false;
  String _lastStatus = '';
  bool _lastSuccess = true;

  Future<void> _sendTestEvent() async {
    setState(() {
      _isSending = true;
      _lastSuccess = true;
      _lastStatus = 'Sending test event...';
    });

    try {
      await UserAnalyticsService.instance.trackTestEvent();
      setState(() {
        _lastSuccess = true;
        _lastStatus = '✅ Test event sent successfully!';
      });
    } catch (e) {
      setState(() {
        _lastSuccess = false;
        _lastStatus = '❌ Failed to send test event: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _sendCustomEvent() async {
    setState(() {
      _isSending = true;
      _lastSuccess = true;
      _lastStatus = 'Sending custom event...';
    });

    try {
      await UserAnalyticsService.instance.trackUserAction(
        'custom_test_event',
        properties: {
          'button_clicked': 'custom_button',
          'screen': 'amplitude_test_screen',
          'user_action': 'testing_custom_event',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      setState(() {
        _lastSuccess = true;
        _lastStatus = '✅ Custom event sent successfully!';
      });
    } catch (e) {
      setState(() {
        _lastSuccess = false;
        _lastStatus = '❌ Failed to send custom event: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _testFunnelEvents() async {
    setState(() {
      _isSending = true;
      _lastSuccess = true;
      _lastStatus = 'Testing funnel events...';
    });

    try {
      await UserAnalyticsService.instance.trackTrainerProfilePublished(
        properties: {
          'has_tagline': true,
          'has_description': true,
          'has_specializations': true,
          'profile_completion_score': 0.8,
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));

      await UserAnalyticsService.instance.trackInboundRequestReceived(
        requestId: 'test_req_123',
        clientUserId: 'test_client_456',
        properties: {
          'request_type': 'booking',
          'client_level': 'beginner',
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));

      await UserAnalyticsService.instance.trackBookingAccepted(
        bookingId: 'test_booking_789',
        clientUserId: 'test_client_456',
        properties: {
          'booking_type': 'personal_training',
          'session_count': 1,
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));

      await UserAnalyticsService.instance.trackPayoutReceived(
        payoutId: 'test_payout_abc',
        amount: 99.99,
        currency: 'USD',
        properties: {
          'commission_amount': 9.99,
          'net_amount': 90.00,
          'time_to_first_payout_days': 7,
        },
      );

      setState(() {
        _lastSuccess = true;
        _lastStatus =
            '✅ Funnel events sent successfully!\n\n🎯 Time-to-First-Dollar funnel:\n1. Profile Published ✅\n2. Inbound Request ✅\n3. Booking Accepted ✅\n4. Payout Received ✅';
      });
    } catch (e) {
      setState(() {
        _lastSuccess = false;
        _lastStatus = '❌ Failed to send funnel events: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    final topInset = AmbientScaffoldShell.topContentInset(context);
    final bottomInset = AmbientScaffoldShell.bottomContentInset(context);
    final statusColor = _lastSuccess
        ? instrument.successColor
        : instrument.peakEffortColor;

    return AmbientScaffoldShell(
      appBar: PrimaryAppBar.detail(title: 'Amplitude Test'),
      body: ResponsiveContainer(
        maxWidth: Breakpoints.maxContentWidthNarrow,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            topInset + 12,
            16,
            bottomInset + 24,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: InstrumentTheme.instrumentCardDecoration(
                context,
                accentColor: instrument.workingAura,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: instrument.workingAura,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'TELEMETRY DIAGNOSTICS',
                          style: InstrumentTheme.microLabel(
                            context,
                            color: instrument.workingAura,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Amplitude Analytics Test',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Test your Amplitude integration by sending events to analytics.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  InstrumentActionButton(
                    label: 'Send Test Event',
                    icon: Icons.bolt_rounded,
                    loading: _isSending,
                    expanded: true,
                    onPressed: _isSending ? null : _sendTestEvent,
                  ),
                  const SizedBox(height: 10),
                  InstrumentActionButton(
                    label: 'Send Custom Event',
                    icon: Icons.analytics_outlined,
                    variant: InstrumentActionVariant.secondary,
                    expanded: true,
                    onPressed: _isSending ? null : _sendCustomEvent,
                  ),
                  const SizedBox(height: 10),
                  InstrumentActionButton(
                    label: 'Show Debug Info',
                    icon: Icons.bug_report_outlined,
                    variant: InstrumentActionVariant.secondary,
                    expanded: true,
                    onPressed: () {
                      UserAnalyticsService.instance.debugInfo();
                      setState(() {
                        _lastSuccess = true;
                        _lastStatus = '🔍 Debug info logged to console';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  InstrumentActionButton(
                    label: 'Test Time-to-First-Dollar Funnel',
                    icon: Icons.trending_up_rounded,
                    variant: InstrumentActionVariant.secondary,
                    expanded: true,
                    onPressed: _isSending ? null : _testFunnelEvents,
                  ),
                ],
              ),
            ),
            if (_lastStatus.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: InstrumentTheme.instrumentCardDecoration(
                  context,
                  accentColor: statusColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lastSuccess ? 'DISPATCH RESULT' : 'DISPATCH ERROR',
                      style: InstrumentTheme.microLabel(
                        context,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastStatus,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
