
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:hierarchy/utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TreeView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'TreeView Demo'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final globalKey = GlobalKey<ScaffoldState>();
  Map<TreeNode, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: TreeView.simple(
        tree: TreeNode.root(data: ""),
        expansionBehavior: ExpansionBehavior.scrollToLastChild,
        shrinkWrap: true,
        showRootNode: true,
        builder: (context, node) =>
        node.isRoot ? buildRootItem(node) : buildListItem(node),
      ),
    );
  }

  Widget buildRootItem(TreeNode node) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ListTile(
              title: Text("${node.data}"),
              subtitle: Text('Level ${node.level}'),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildRootAddItemChildButton(node),
                if (node.children.isNotEmpty) buildClearAllItemButton(node)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListItem(TreeNode node) {
    _controllers.putIfAbsent(node, () => TextEditingController());

    return Card(
      color: colorMapper[node.level.clamp(0, colorMapper.length - 1)]!,
      child: ListTile(
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: TextFormField(
              controller: _controllers[node],
              decoration: InputDecoration(
                hintText: "input key",
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.name,
            ),
          ),
        ),
        subtitle: Text('Level ${node.level}'),
        dense: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildRemoveItemButton(node),
            buildAddItemButton(node),
          ],
        ),
      ),
    );
  }

  Widget buildAddItemButton(TreeNode item) {
    return IconButton(
      onPressed: () {
        String value = _controllers[item]?.text ?? '';
        item.add(TreeNode(data: value));
      },
      icon: Icon(Icons.add_circle, color: Colors.green),
    );
  }

  Widget buildRemoveItemButton(TreeNode item) {
    return IconButton(
      onPressed: () {
        _controllers.remove(item)?.dispose();
        item.delete();
      },
      icon: Icon(Icons.delete, color: Colors.red),
    );
  }

  Widget buildRootAddItemChildButton(TreeNode item) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.green[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        icon: Icon(Icons.add_circle, color: Colors.green),
        label: Text("Add Child", style: TextStyle(color: Colors.green)),
        onPressed: () {
          item.add(TreeNode(data: "root"));
        },
      ),
    );
  }

  Widget buildClearAllItemButton(TreeNode item) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.red[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        icon: Icon(Icons.delete, color: Colors.red),
        label: Text("Clear All", style: TextStyle(color: Colors.red)),
        onPressed: () {
          item.clear();
        },
      ),
    );
  }

  Widget inputKeyTextField({required TreeNode item, required String type}) {
    _controllers.putIfAbsent(item, () => TextEditingController());

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      content: Container(
        height: MediaQuery.of(context).size.width * 0.1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("Key"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: TextFormField(
                  controller: _controllers[item],
                  decoration: InputDecoration(
                    hintText: "input key",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.name,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            _controllers[item]?.clear();
          },
          child: const Text(
            'الغاء',
            style: TextStyle(color: Colors.black),
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            side: BorderSide(width: 2, color: Colors.black),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            String value = _controllers[item]?.text ?? '';
            type == "parent" ? item.add(TreeNode(data: value)) : item.add(TreeNode(data: value));
            Navigator.pop(context);
            _controllers[item]?.clear();
          },
          child: const Text(
            'حفظ',
            style: TextStyle(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Colors.green,
            side: BorderSide(width: 2, color: Colors.green),
          ),
        ),
      ],
    );
  }
}


