import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tbbt.dart';
import 'package:google_fonts/google_fonts.dart';


/// Flutter code sample for [BottomAppBar].

void main() {
  runApp(const BottomAppBarDemo());
}

class BottomAppBarDemo extends StatefulWidget {
  const BottomAppBarDemo({super.key});

  @override
  State createState() => _BottomAppBarDemoState();
}

class _BottomAppBarDemoState extends State<BottomAppBarDemo> {
  FloatingActionButtonLocation _fabLocation =
      FloatingActionButtonLocation.endDocked;

  bool darkTheme = false;
  bool showChinese = true;
  int season = 0;
  int episode = 0;
  double offset = 0.0;
  List<String> favorites = [];
  Set<String> favoritesSet = {};
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAppState();
    _controller.addListener(() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('offset', _controller.offset);});
  }


  Future<void> _loadAppState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      darkTheme = prefs.getBool('darkTheme') ?? false;
      showChinese = prefs.getBool('showChinese') ?? true;
      season = prefs.getInt('season') ?? 0;
      episode = prefs.getInt('episode') ?? 0;
      offset = prefs.getDouble('offset') ?? 0.0;
      favorites = prefs.getStringList('favorites') ?? [];
      _controller.jumpTo(offset);
    });
  }

  Future<void> _saveTheme() async{SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('darkTheme', darkTheme);}

  Future<void> _saveShowChinese() async{SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('showChinese', showChinese);}

  Future<void> _saveEpisode() async{SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('season', season);
  await prefs.setInt('episode', episode);}

  Future<void> _saveFavorites() async{SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('favorites', favorites);}

  void toggleChinese(){
    setState(() {
      showChinese = !showChinese;
    });
    _saveShowChinese();
  }

  void darkMode(){
    setState(() {
      darkTheme = !darkTheme;
    });
    _saveTheme();
  }


  void addToFavorites(String? item1, String? item2) {
    setState(() {
      favoritesSet.add('$item1|$item2');
      favorites = favoritesSet.toList();
    });
    _saveFavorites();
  }

  void removeFavorites(String? item1, String? item2) {
    setState(() {
      favoritesSet.remove('$item1|$item1');
      favorites = favoritesSet.toList();
    });
    _saveFavorites();
  }



  void showFavorite(BuildContext context){
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return favorites.isNotEmpty? Container(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              height: 2000, // 设置底部弹出面板的高度
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: favorites.length,
                itemBuilder: (context, index){
                  var group = favorites[index].split('|');

                  return  Dismissible(
                    key: Key(favorites[index]), // 必须提供一个唯一的key
                    direction: DismissDirection.horizontal, // 滑动方向
                    onDismissed: (direction) {
                      setState(() {
                        favoritesSet.remove(favorites[index]);
                        favorites = favoritesSet.toList();
                      });

                      _saveFavorites();
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(child: ListTile(title: Text(group[0], style: GoogleFonts.patrickHand(textStyle: const TextStyle(fontSize: 20))), subtitle: Text(group[1], style: GoogleFonts.maShanZheng(textStyle: const TextStyle(fontSize: 18))),)) ,
                  );
                },
              )

          ):  Center(child: Text('Empty', style: GoogleFonts.patrickHand(),),);
        });
  }




  void showAll(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 2000, // 设置底部弹出面板的高度
          child:
          // Scrollbar
          //   thumbVisibility: true,
          //   child:
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: cc.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              return Container(
                width: 150, // 设置列表项的宽度
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.asset('lib/assets/1.jpg'),
                        Text('S${index+1}', style: GoogleFonts.fascinateInline(textStyle: const TextStyle(fontSize: 36, color: Colors.white) ), )
                      ],
                    ),

                    const SizedBox(height: 8),
                    Expanded(

                      //height: 150, // Height of the vertical ListView
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: cc[index].length, // Number of vertical items
                        separatorBuilder: (BuildContext context, int index) => const Divider(
                          height: 1, // 分割线高度
                          color: Colors.grey, // 分割线颜色
                        ),
                        itemBuilder: (BuildContext context, int subIndex) {
                          return ListTile(
                            title: Text('Episode ${subIndex+1}', style: GoogleFonts.patrickHand() ,), // Vertical item label
                            onTap: (){setState(() {
                              season = index;
                              episode = subIndex;
                            });
                            _saveEpisode();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: darkTheme? const ColorScheme.dark(): const ColorScheme.light(),
        // textTheme: GoogleFonts.notoSerifTextTheme(),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Season ${season+1} - Episode ${episode+1}', style: GoogleFonts.fascinateInline(),),
          actions: <Widget>[
            ToggleButtons(
              renderBorder: false,
              
              isSelected: [showChinese, darkTheme],
              onPressed: (index) {
                if(index == 0){
                  toggleChinese();
                }
                else{
                  darkMode();
                }
              },
              children: <Widget>[
                Icon(showChinese? Icons.subtitles_off:Icons.subtitles, color: Colors.lightGreen,),
                Icon(darkTheme? Icons.light_mode: Icons.dark_mode,  color: Colors.lightGreen,),
              ],
            ),
          ],
        ),
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
            controller: _controller,
            itemCount: cc[season][episode].length,
            itemBuilder: (context, index){
              return 
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: 
                  Dismissible(
                    key: Key(cc[season][episode][index][0]),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      addToFavorites(cc[season][episode][index][0], cc[season][episode][index][1]);
                      return false;
                    },
                    // dismissThresholds: const {DismissDirection.endToStart: 0.5}

                    background: Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 0, 0.0, 0),
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.favorite, color: Colors.red),
                    ),

                    secondaryBackground: Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20.0, 0),
                      color: Colors.green,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.favorite, color: Colors.red),
                    ),

                    child:Card(child: ListTile(
                      subtitle: showChinese? Text(cc[season][episode][index][1], style: GoogleFonts.maShanZheng(textStyle: const TextStyle(fontSize: 18)),) : const Text(''),
                      title: SelectableText(
                        cc[season][episode][index][0],
                        onTap: () {
                        },
                        style: GoogleFonts.patrickHand(textStyle: const TextStyle(fontSize: 20)) 
                      ),
                    ),) ,
                  ),);

            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {_controller.animateTo(_controller.offset+600, duration: const Duration(seconds: 1), curve: Curves.easeInOut,);},
          tooltip: 'Auto',
          child: const Icon(Icons.play_arrow),
        ),

        floatingActionButtonLocation: _fabLocation,
        bottomNavigationBar: _DemoBottomAppBar(
          fabLocation: _fabLocation,
          shape: const CircularNotchedRectangle(),
          lastChapter: (){
            setState(() {
              if (episode == 0&&season==0){
                return;
              }
              if (episode==0){
                season--;
                episode = cc[season].length-1;
                return;
              }
              episode--;
            });
            _saveEpisode();
          },
          showChapters: showAll,
          showFavoriteItmes: showFavorite,
          nextChapters: (){setState(() {
            if(season==cc.length-1&&episode==cc[season].length-1){
              return;
            }
            if(episode < cc[season].length-1)
            {episode++;}
            else{
              episode = 0;
              season++;
            }
          });
          _saveEpisode();
          },

        ),
      ),
    );
  }
}


class _DemoBottomAppBar extends StatelessWidget {
  const _DemoBottomAppBar({
    this.fabLocation = FloatingActionButtonLocation.endDocked,
    this.shape = const CircularNotchedRectangle(),
    required this.lastChapter,
    required this.showChapters,
    required this.nextChapters,
    required this.showFavoriteItmes,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final Function lastChapter;
  final Function showChapters;
  final Function nextChapters;
  final Function showFavoriteItmes;


  static final List<FloatingActionButtonLocation> centerLocations =
  <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: shape,
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Select Season and episode',
            icon: const Icon(Icons.menu),
            onPressed: (){
              showChapters(context);
            },
          ),
          if (centerLocations.contains(fabLocation)) const Spacer(),
          IconButton(
            tooltip: 'Previous episode',
            icon: const Icon(Icons.skip_previous),
            onPressed: () {
              lastChapter();
            },
          ),
          IconButton(
            tooltip: 'Next episode',
            icon: const Icon(Icons.skip_next),
            onPressed: () {
              nextChapters();
            },
          ),
          IconButton(
            tooltip: 'Next episode',
            icon: const Icon(Icons.favorite),
            onPressed: () {
              showFavoriteItmes(context);
            },
          ),
        ],
      ),
    );
  }
}
