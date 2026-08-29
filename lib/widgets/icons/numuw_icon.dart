import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Production vector icon wrapper for Numuw's custom icon family.
/// SVG assets are monochrome and recolored at runtime for Morning/Evening.
class NumuwIcon extends StatelessWidget {
  const NumuwIcon(
    this.asset, {
    super.key,
    this.size = 22,
    this.color,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: semanticLabel,
      colorFilter: resolvedColor == null
          ? null
          : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}

class NumuwIcons {
  const NumuwIcons._();
  static const _root = 'assets/icons';

  static const logoMark = '$_root/logo_mark.svg';
  static const home = '$_root/home.svg';
  static const quickLog = '$_root/quick_log.svg';
  static const child = '$_root/child.svg';
  static const assistant = '$_root/assistant.svg';
  static const more = '$_root/more.svg';
  static const feeding = '$_root/feeding.svg';
  static const feedingRight = '$_root/feeding_right.svg';
  static const feedingLeft = '$_root/feeding_left.svg';
  static const bottle = '$_root/bottle.svg';
  static const formula = '$_root/formula.svg';
  static const pumping = '$_root/pumping.svg';
  static const pumpingLeft = '$_root/pumping_left.svg';
  static const pumpingRight = '$_root/pumping_right.svg';
  static const sleep = '$_root/sleep.svg';
  static const wake = '$_root/wake.svg';
  static const diaper = '$_root/diaper.svg';
  static const diaperWet = '$_root/diaper_wet.svg';
  static const diaperDirty = '$_root/diaper_dirty.svg';
  static const food = '$_root/food.svg';
  static const medicine = '$_root/medicine.svg';
  static const temperature = '$_root/temperature.svg';
  static const note = '$_root/note.svg';
  static const vaccination = '$_root/vaccination.svg';
  static const growth = '$_root/growth.svg';
  static const weight = '$_root/weight.svg';
  static const height = '$_root/height.svg';
  static const headCircumference = '$_root/head_circumference.svg';
  static const milestones = '$_root/milestones.svg';
  static const playActivity = '$_root/play_activity.svg';
  static const doctor = '$_root/doctor.svg';
  static const doctorReport = '$_root/doctor_report.svg';
  static const prescription = '$_root/prescription.svg';
  static const pdf = '$_root/pdf.svg';
  static const pregnancy = '$_root/pregnancy.svg';
  static const hospitalBag = '$_root/hospital_bag.svg';
  static const shopping = '$_root/shopping.svg';
  static const mealPlan = '$_root/meal_plan.svg';
  static const mother = '$_root/mother.svg';
  static const water = '$_root/water.svg';
  static const mood = '$_root/mood.svg';
  static const breathing = '$_root/breathing.svg';
  static const family = '$_root/family.svg';
  static const caregiver = '$_root/caregiver.svg';
  static const tasks = '$_root/tasks.svg';
  static const checklist = '$_root/checklist.svg';
  static const article = '$_root/article.svg';
  static const audio = '$_root/audio.svg';
  static const community = '$_root/community.svg';
  static const weeklyReport = '$_root/weekly_report.svg';
  static const chart = '$_root/chart.svg';
  static const premium = '$_root/premium.svg';
  static const camera = '$_root/camera.svg';
  static const documents = '$_root/documents.svg';
  static const upload = '$_root/upload.svg';
  static const microphone = '$_root/microphone.svg';
  static const voiceWave = '$_root/voice_wave.svg';
  static const timer = '$_root/timer.svg';
  static const emergency = '$_root/emergency.svg';
  static const source = '$_root/source.svg';
  static const location = '$_root/location.svg';
  static const share = '$_root/share.svg';
  static const settings = '$_root/settings.svg';
  static const privacy = '$_root/privacy.svg';
  static const language = '$_root/language.svg';
  static const childAdd = '$_root/child_add.svg';
  static const logout = '$_root/logout.svg';
  static const email = '$_root/email.svg';
  static const moon = '$_root/moon.svg';
  static const edit = '$_root/edit.svg';
  static const info = '$_root/info.svg';
  static const back = '$_root/back.svg';
  static const add = '$_root/add.svg';
  static const check = '$_root/check.svg';
  static const search = '$_root/search.svg';
  static const bell = '$_root/bell.svg';
  static const calendar = '$_root/calendar.svg';
  static const profile = '$_root/profile.svg';
  static const history = '$_root/history.svg';

  /// CI validates every registered asset. Add new SVGs here immediately.
  static const all = <String>{
    logoMark,
    home,
    quickLog,
    child,
    assistant,
    more,
    feeding,
    feedingRight,
    feedingLeft,
    bottle,
    formula,
    pumping,
    pumpingLeft,
    pumpingRight,
    sleep,
    wake,
    diaper,
    diaperWet,
    diaperDirty,
    food,
    medicine,
    temperature,
    note,
    vaccination,
    growth,
    weight,
    height,
    headCircumference,
    milestones,
    playActivity,
    doctor,
    doctorReport,
    prescription,
    pdf,
    pregnancy,
    hospitalBag,
    shopping,
    mealPlan,
    mother,
    water,
    mood,
    breathing,
    family,
    caregiver,
    tasks,
    checklist,
    article,
    audio,
    community,
    weeklyReport,
    chart,
    premium,
    camera,
    documents,
    upload,
    microphone,
    voiceWave,
    timer,
    emergency,
    source,
    location,
    share,
    settings,
    privacy,
    language,
    childAdd,
    logout,
    email,
    moon,
    edit,
    info,
    back,
    add,
    check,
    search,
    bell,
    calendar,
    profile,
    history,
  };
}
