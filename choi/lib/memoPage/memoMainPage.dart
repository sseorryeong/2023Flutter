// 메모 페이지
// 앱의 상태를 변경해야하므로 StatefulWidget 상속
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_memo_app/memoPage/memoDB.dart';
import 'package:flutter_memo_app/memoPage/memoListProvider.dart';
import 'package:provider/provider.dart';

import 'memoDetailPage.dart';

class MyMemoPage extends StatefulWidget {
  const MyMemoPage({super.key});

  @override
  MyMemoState createState() => MyMemoState();
}

class MyMemoState extends State<MyMemoPage> {
  // 검색어
  String searchText = '';

  // 플로팅 액션 버튼을 이용하여 항목을 추가할 제목과 내용
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // 메모 리스트 저장 변수
  List items = [];

  // 메모 리스트 출력
  Future<void> getMemoList() async {
    List memoList = [];
    // DB에서 메모 정보 호출
    var result = await selectMemoALL();

    print(result?.numOfRows);

    // 메모 리스트 저장
    for (final row in result!.rows) {
      var memoInfo = {
        'id': row.colByName('id'),
        'userIndex': row.colByName('userIndex'),
        'userName': row.colByName('userName'),
        'memoTitle': row.colByName('memoTitle'),
        'memoContent': row.colByName('memoContent'),
        'createDate': row.colByName('createDate'),
        'updateDate': row.colByName('updateDate')
      };
      memoList.add(memoInfo);
    }

    print('MemoMainPage - getMemoList : $memoList');
    context.read<MemoUpdator>().updateList(memoList);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMemoList();
  }

  // 리스트뷰 카드 클릭 이벤트
  void cardClickEvent(BuildContext context, int index) async {
    dynamic content = items[index];
    print('content : $content');
    // 메모 리스트 업데이트 확인 변수 (false : 업데이트 되지 않음, true : 업데이트 됨)
    var isMemoUpdate = await Navigator.push(
      context,
      MaterialPageRoute(
        // 정의한 ContentPage의 폼 호출
        builder: (context) => ContentPage(content: content),
      ),
    );

    // 메모 수정이 일어날 경우, 메모 메인 페이지의 리스트 새로고침
    if (isMemoUpdate != null) {
      setState(() {
        getMemoList();
        items = Provider.of<MemoUpdator>(context, listen: false).memoList;
      });
    }
  }

  // 플로팅 액션 버튼 클릭 이벤트
  Future<void> addItemEvent(BuildContext context) {
    // 다이얼로그 폼 열기
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('메모 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                ),
              ),
              TextField(
                controller: contentController,
                maxLines: null, // 다중 라인 허용
                decoration: InputDecoration(
                  labelText: '내용',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () async {
                String title = titleController.text;
                String content = contentController.text;
                // 메모 추가
                await addMemo(title, content);

                setState(() {
                  // 메모 리스트 새로고침
                  print("MemoMainPage - addMemo/setState");
                  getMemoList();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색어를 입력해주세요.',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                // 메모 수정이 일어날 경우 메모 리스트 새로고침
                items = context.watch<MemoUpdator>().memoList;

                // 메모가 없을 경우의 페이지
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      "표시할 메모가 없습니다.",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                // 메모가 있을 경우의 페이지
                else {
                  // items 변수에 저장되어 있는 모든 값 출력
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      // 메모 정보 저장
                      dynamic memoInfo = items[index];
                      String userName = memoInfo['userName'];
                      String memoTitle = memoInfo['memoTitle'];
                      String memoContent = memoInfo['memoContent'];
                      String createDate = memoInfo['createDate'];
                      String updateDate = memoInfo['updateDate'];

                      // 검색 기능, 검색어가 있을 경우, 제목으로만 검색
                      if (searchText.isNotEmpty &&
                          !items[index]['memoTitle']
                              .toLowerCase()
                              .contains(searchText.toLowerCase())) {
                        return SizedBox.shrink();
                      }
                      // 검색어가 없을 경우
                      // 혹은 모든 항목 표시
                      else {
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.elliptical(20, 20))),
                          child: ListTile(
                            leading: Text(userName),
                            title: Text(memoTitle),
                            subtitle: Text(memoContent),
                            trailing: Text(updateDate),
                            onTap: () => cardClickEvent(context, index),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      // 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () => addItemEvent(context), // 버튼을 누를 경우 메모 추가 UI 표시
        tooltip: 'Add Item', // 플로팅 액션 버튼 설명
        child: Icon(Icons.add), // + 모양 아이콘
      ),
    );
  }
}
