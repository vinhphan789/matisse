import 'package:flutter/material.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/view_model/language_viewmodel.dart';
import '../extension/app_router.dart';
import '../colors/colors_app.dart';


class LanguagePage extends StatefulWidget {
  final String? selected;

  const LanguagePage({
    super.key,
    this.selected = '',

  });

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final LanguageViewModel vm = LanguageViewModel();
  String? _selected;
  String _keyword = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selected = widget.selected;

    print("👉 _selected init: $_selected"); // xem giá trị là gì

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.fetchLanguage();
    });
  }



    @override
    Widget build(BuildContext context) {

      return AnimatedBuilder(
        animation: vm, // 👈 LISTEN Ở ĐÂY
        builder: (context, _) {
          // Lọc theo search
          final filtered = vm.languages.where((e) {
            return e.key.toLowerCase().contains(_keyword.toLowerCase());
          }).toList();

          return Scaffold(
            backgroundColor: ColorApp.blackMain1E1E1E,
            appBar: AppBar(
              backgroundColor: ColorApp.blackMain1E1E1E,
              title: const SetupTextWidget(
                titleLabel: "Language",
                textColor: ColorApp.whiteMainColor,
                textAlign: TextAlign.start,
                fontSize: 20,
                font: FontApp.robotoBold,
                maxLine: 1,
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32,),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Body + bottom button
            body: Column(
              children: [
                // SEARCH BAR
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => setState(() => _keyword = v),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.white, size: 24,),
                          filled: true,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.xs4),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    )
                ),

                // LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final lang = filtered[i];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ROW: RADIO + TITLE (center nhau)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center, // 👈 key
                              children: [
                                Radio<String>(
                                  value: lang.value,
                                  groupValue: _selected,
                                  activeColor: Colors.lightBlue,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (v) => setState(() => _selected = v),
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  lang.value,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),

                            // SUBTITLE (thụt vào bằng radio width)
                            Padding(
                              padding: const EdgeInsets.only(left: 48), // 👈 chỉnh theo radio size
                              child: Text(
                                lang.value,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // SAVE BUTTON

              ],
            ),

            bottomNavigationBar: Container(
              color: ColorApp.gray2A2A2AColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.blueMainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.xs4),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            print({_selected});
                            Navigator.pop(context, _selected);
                          },
                          child: const SetupTextWidget(titleLabel: 'SAVE', font: FontApp.robotoRegular, fontSize: 15,),
                        ),
                      ),
                      Spacer()
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
