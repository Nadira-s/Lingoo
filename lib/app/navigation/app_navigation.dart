import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void openNewBooking(BuildContext context) => context.push('/bookings/new');

void openBookingDetail(BuildContext context, int id) =>
    context.push('/bookings/$id');

void openBookingsSchedule(BuildContext context) =>
    context.push('/bookings/schedule');
