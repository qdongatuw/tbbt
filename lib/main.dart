import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'tbbt.dart';


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
  final FloatingActionButtonLocation _fabLocation =
      FloatingActionButtonLocation.endDocked;

  bool darkTheme = false;
  bool showChinese = true;
  int season = 0;
  int episode = 0;
  double offset = 0.0;
  List<String> favorites = [];
  Set<String> favoritesSet = {};
  final ScrollController _controller = ScrollController();

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

  Future<Map<String, dynamic>> _queryData(BuildContext context, String word) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final dbPath = join(documentsDirectory.path, 'my_database.db');
  AssetBundle bundle = DefaultAssetBundle.of(context);
  final dbFile = File(dbPath);
  if (!dbFile.existsSync()) {
    final data = await bundle.load('lib/assets/my_database.db');
    await dbFile.writeAsBytes(data.buffer.asUint8List());
  }

  final db = await openDatabase(dbFile.path, readOnly: true);

  final result = await db.rawQuery(
    'SELECT phonetic, definition, translation FROM dictionary WHERE word = ?',
    [word],
  );

  await db.close();

  if (result.isNotEmpty) {
    return result.first;
  } else {
    return {}; // Return an empty map if no results are found
  }
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

  void fetchDictionary(BuildContext context, String text){
    String textLower = text.toLowerCase().trim();

    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context){
        return FutureBuilder(
          future: _queryData(context, textLower),
          builder: (context, snapshot) {
          if(snapshot.hasData){
            final data = snapshot.data!;
          if (data.isNotEmpty){
            return Container(
              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(60)),),
              padding: const EdgeInsets.all(8.0),
              height:400,
              child: ListTile(
                title: Row(children: [Text(textLower, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),), const SizedBox(width: 5,), Text(data['phonetic'], style: const TextStyle(color: Colors.grey),),],),
                subtitle: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    Text('Definition: \n${data['definition'].replaceAll('\\n', '\n')}'),
                    const SizedBox(height: 5,),
                    Text('中文释义: \n${data['translation'].replaceAll('\\n', '\n')}'),
              ],
            ),) 
              ),
              
            );
          }
           else {
            return const SizedBox(
              height:300,
              child: Center(child: Text("Not found."),) );
          }
        }
      else{
        return const SizedBox(
              height:300,
              child: Center(child: Text("Not found."),) );
      }
          }
          
          
        );
      });
  }

  void showFavorite(BuildContext context){
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return favorites.isNotEmpty? Container(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              height: 600, // 设置底部弹出面板的高度
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
                    child: Card(
                      child: ListTile(
                        title:SelectableText(
                        group[0],
                        onSelectionChanged: (TextSelection selection, _) {
                          String text = group[0].substring(selection.baseOffset ,selection.extentOffset);
                          if(text.isNotEmpty){
                            fetchDictionary(context, text);
                          }
                        },
                        style:  const TextStyle(fontFamily: 'Itim', fontSize: 20) 
                      ), 
                        subtitle: Text(group[1], style: const TextStyle(fontSize: 18)),
                        )
                        ) ,
                  );
                },
              )

          ):  const SizedBox(
            height: 300,
            child: Center(child: Text('Empty', style: TextStyle(fontFamily: 'Itim'),),) ,
            );
        });
  }

  void showAll(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 600, // 设置底部弹出面板的高度
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
                        Text('S${index+1}', style:  const TextStyle(fontFamily: 'Cursive', fontSize: 36, color: Colors.white) , )
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
                            title: Text('Episode ${subIndex+1}', style: const TextStyle(fontFamily: 'Cursive') ,), // Vertical item label
                            onTap: (){setState(() {
                              season = index;
                              episode = subIndex;
                              _controller.jumpTo(0);
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
          title: Text('Season ${season+1} - Episode ${episode+1}', style: const TextStyle(fontFamily: 'Cursive'),),
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
              var item = cc[season][episode][index];
              return 
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: 
                  Dismissible(
                    key: Key(item[0]),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      addToFavorites(item[0], item[1]);
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
                      subtitle: showChinese? Text(item[1], style: const TextStyle(fontSize: 18),) : const Text(''),
                      title: SelectableText(
                        item[0],
                        onSelectionChanged: (TextSelection selection, _) {
                          String text = item[0].substring(selection.baseOffset ,selection.extentOffset);
                          if(text.isNotEmpty){
                            fetchDictionary(context, text);
                          }
                        },
                        style:  const TextStyle(fontFamily: 'Itim', fontSize: 20) 
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
            _controller.jumpTo(0);
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
          _controller.jumpTo(0);
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
