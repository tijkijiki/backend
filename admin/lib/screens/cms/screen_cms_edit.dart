import 'dart:async';
import 'dart:html';

import 'package:admin/components/gallery_picker/fnx_gallery_picker.dart';
import 'package:admin/shared/create_edit_support.dart';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:api_client/api.dart';
import 'package:fnx_rest/fnx_rest.dart';
import 'package:fnx_ui/components/fnx_app/fnx_app.dart';
import 'package:fnx_ui/fnx_ui.dart';

///
/// ScreenNewsEdit
///
@Component(selector: 'screen-cms-edit', templateUrl: 'screen_cms_edit.html', directives: [fnxUiAllDirectives, coreDirectives, formDirectives, FnxGalleryPicker])
class ScreenCmsEdit with CreateEditSupport implements OnActivate {
  final FnxApp fnxApp;
  final RestClient root;
  RestClient rest;
  String id;

  final Router router;

  CmsArticleEntity entity;

  String type;

  bool logModalVisible = false;

  RestClient logRest;

  @override
  get data => entity;

  @override
  String get dataId => id;

  ///
  /// Defines image set. Mainly the ratio you want to enforce in certain types of images.
  ///
  FnxImageSet imageSet = new FnxImageSet("news", "News", 1.3333);

  ScreenCmsEdit(this.root, this.router, this.fnxApp) {
    rest = root.child('/v1/cms/articles');
  }

  Future<bool> fetchDetails() async {
    RestResult rr = await rest.child('/$id').get();

    if (rr.success) {
      entity = CmsArticleEntity.fromJson(rr.data);
      if (type != entity.type) {
        throw "Something is wrong. Received article type '${entity.type}' != expected '$type'";
      }
      if (entity.data == null) entity.data = {};
      return true;
    } else {
      return false;
    }
  }

  bool get creating => id == null || id == 'create';

  Future<bool> saveArticle(Event e) async {
    e.preventDefault();
    RestResult rr = await (creating ? rest.post(entity.toJson()) : rest.child(id).put(entity.toJson()));
    if (rr.success) {
      fnxApp.toast('Article has been created');
      //router.current.;
      return true;
    } else if (rr.data['error']) {
      fnxApp.alert('Error while trying to save article: ${rr.data['error']}');
    } else {
      fnxApp.alert('Error while trying to save article');
    }
    return false;
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    type = current.parameters['type'];
    id = current.parameters['id'] ?? int.tryParse(current.parameters['id']);

    if (isCreate) {
      entity = CmsArticleEntity()
        ..type = type
        ..data = {};
    }
    if (isEdit) {
      fetchDetails();
    }

    logRest = root.child("/v1/cms/articles/${id}/log");
  }
}
