import 'package:calender_scheduler/component/calendar.dart';
import 'package:calender_scheduler/component/schedule_card.dart';
import 'package:calender_scheduler/component/today_banner.dart';
import 'package:calender_scheduler/const/colors.dart';
import 'package:calender_scheduler/database/drift_database.dart';
import 'package:calender_scheduler/schedule_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day
  );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: renderFloatingActionButton(),
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
            ),
            SizedBox(height: 8.0),
            TodayBanner(
                selectedDay: selectedDay,
                scheduleCount: 3,
            ),
            SizedBox(height: 8.0),
            _ScheduleList(selectedDate: selectedDay,),
          ],
        ),
      ),
    );
  }

  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_){
              return ScheduleBottomSheet(
                selectedDate: selectedDay,
              );
            },
        );
      },
      backgroundColor: PRIMARY_COLOR,
      child: Icon(Icons.add),);
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay){
    setState(() {
      this.selectedDay = selectedDay;
      // 전,다음 달 날짜를 눌렀을 경우, 달력도 움직이게 하는 것
      this.focusedDay = selectedDay;
    });
  }
}

class _ScheduleList extends StatelessWidget {
  final DateTime selectedDate;
  const _ScheduleList({required this.selectedDate, Key? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<List<Schedule>>(
          stream: GetIt.I<LocalDatabase>().watchSchedule(selectedDate),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator()
              );
            }
            if(snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Text('스케줄이 없습니다.'),
              );
            }
            return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 8.0);
                },
                itemBuilder: (context, index){
                  final schedule = snapshot.data![index];
                  return  ScheduleCard(
                      startTime: schedule.startTime,
                      endTime: schedule.endTime,
                      content:schedule.content,
                      color: Colors.red);
                }
            );
          }
        ),
      ),
    );
  }
}

