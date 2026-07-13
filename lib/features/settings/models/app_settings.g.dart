// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      pageDirection: fields[0] == null
          ? PageDirection.leftToNext
          : fields[0] as PageDirection,
      theme: fields[2] == null ? AppTheme.system : fields[2] as AppTheme,
      sidebarPosition: fields[3] == null
          ? SidebarPosition.left
          : fields[3] as SidebarPosition,
      lastOpenBookId: fields[4] as String?,
      tabBarPosition:
          fields[5] == null ? TabBarPosition.top : fields[5] as TabBarPosition,
      fullscreenBehavior: fields[6] == null
          ? FullscreenBehavior.onViewerOnly
          : fields[6] as FullscreenBehavior,
      outerEdgeElement: fields[7] == null
          ? OuterEdgeElement.verticalTabs
          : fields[7] as OuterEdgeElement,
      launchTabBehavior: fields[8] == null
          ? LaunchTabBehavior.resumeLastBook
          : fields[8] as LaunchTabBehavior,
      savedTabsJson: fields[9] as String?,
      middleClickTabBehavior: fields[10] == null
          ? MiddleClickTabBehavior.switchToNewTab
          : fields[10] as MiddleClickTabBehavior,
      mobileNavIconOrder: fields[13] == null
          ? [
              'back',
              'forward',
              'search',
              'addTab',
              'tabCount',
              'favorites',
              'settings',
              'addFolder'
            ]
          : (fields[13] as List).cast<String>(),
      mobileNavHiddenIcons:
          fields[14] == null ? [] : (fields[14] as List).cast<String>(),
      screenOrientationLock: fields[15] == null
          ? ScreenOrientationLock.portraitUp
          : fields[15] as ScreenOrientationLock,
      settingsFavoritesOpenMode: fields[16] == null
          ? SettingsFavoritesOpenMode.newTab
          : fields[16] as SettingsFavoritesOpenMode,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.pageDirection)
      ..writeByte(2)
      ..write(obj.theme)
      ..writeByte(3)
      ..write(obj.sidebarPosition)
      ..writeByte(4)
      ..write(obj.lastOpenBookId)
      ..writeByte(5)
      ..write(obj.tabBarPosition)
      ..writeByte(6)
      ..write(obj.fullscreenBehavior)
      ..writeByte(7)
      ..write(obj.outerEdgeElement)
      ..writeByte(8)
      ..write(obj.launchTabBehavior)
      ..writeByte(9)
      ..write(obj.savedTabsJson)
      ..writeByte(10)
      ..write(obj.middleClickTabBehavior)
      ..writeByte(13)
      ..write(obj.mobileNavIconOrder)
      ..writeByte(14)
      ..write(obj.mobileNavHiddenIcons)
      ..writeByte(15)
      ..write(obj.screenOrientationLock)
      ..writeByte(16)
      ..write(obj.settingsFavoritesOpenMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TabModeAdapter extends TypeAdapter<TabMode> {
  @override
  final int typeId = 3;

  @override
  TabMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TabMode.fixedLibrary;
      case 1:
        return TabMode.independent;
      default:
        return TabMode.fixedLibrary;
    }
  }

  @override
  void write(BinaryWriter writer, TabMode obj) {
    switch (obj) {
      case TabMode.fixedLibrary:
        writer.writeByte(0);
        break;
      case TabMode.independent:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SidebarPositionAdapter extends TypeAdapter<SidebarPosition> {
  @override
  final int typeId = 7;

  @override
  SidebarPosition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SidebarPosition.left;
      case 1:
        return SidebarPosition.right;
      default:
        return SidebarPosition.left;
    }
  }

  @override
  void write(BinaryWriter writer, SidebarPosition obj) {
    switch (obj) {
      case SidebarPosition.left:
        writer.writeByte(0);
        break;
      case SidebarPosition.right:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SidebarPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TabBarPositionAdapter extends TypeAdapter<TabBarPosition> {
  @override
  final int typeId = 8;

  @override
  TabBarPosition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TabBarPosition.top;
      case 1:
        return TabBarPosition.left;
      case 2:
        return TabBarPosition.right;
      default:
        return TabBarPosition.top;
    }
  }

  @override
  void write(BinaryWriter writer, TabBarPosition obj) {
    switch (obj) {
      case TabBarPosition.top:
        writer.writeByte(0);
        break;
      case TabBarPosition.left:
        writer.writeByte(1);
        break;
      case TabBarPosition.right:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabBarPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PageDirectionAdapter extends TypeAdapter<PageDirection> {
  @override
  final int typeId = 4;

  @override
  PageDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PageDirection.leftToNext;
      case 1:
        return PageDirection.rightToNext;
      default:
        return PageDirection.leftToNext;
    }
  }

  @override
  void write(BinaryWriter writer, PageDirection obj) {
    switch (obj) {
      case PageDirection.leftToNext:
        writer.writeByte(0);
        break;
      case PageDirection.rightToNext:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeAdapter extends TypeAdapter<AppTheme> {
  @override
  final int typeId = 6;

  @override
  AppTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppTheme.system;
      case 1:
        return AppTheme.light;
      case 2:
        return AppTheme.dark;
      default:
        return AppTheme.system;
    }
  }

  @override
  void write(BinaryWriter writer, AppTheme obj) {
    switch (obj) {
      case AppTheme.system:
        writer.writeByte(0);
        break;
      case AppTheme.light:
        writer.writeByte(1);
        break;
      case AppTheme.dark:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FullscreenBehaviorAdapter extends TypeAdapter<FullscreenBehavior> {
  @override
  final int typeId = 9;

  @override
  FullscreenBehavior read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FullscreenBehavior.onViewerOnly;
      case 1:
        return FullscreenBehavior.alwaysOnLaunch;
      default:
        return FullscreenBehavior.onViewerOnly;
    }
  }

  @override
  void write(BinaryWriter writer, FullscreenBehavior obj) {
    switch (obj) {
      case FullscreenBehavior.onViewerOnly:
        writer.writeByte(0);
        break;
      case FullscreenBehavior.alwaysOnLaunch:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FullscreenBehaviorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OuterEdgeElementAdapter extends TypeAdapter<OuterEdgeElement> {
  @override
  final int typeId = 10;

  @override
  OuterEdgeElement read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OuterEdgeElement.verticalTabs;
      case 1:
        return OuterEdgeElement.sidebar;
      default:
        return OuterEdgeElement.verticalTabs;
    }
  }

  @override
  void write(BinaryWriter writer, OuterEdgeElement obj) {
    switch (obj) {
      case OuterEdgeElement.verticalTabs:
        writer.writeByte(0);
        break;
      case OuterEdgeElement.sidebar:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OuterEdgeElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LaunchTabBehaviorAdapter extends TypeAdapter<LaunchTabBehavior> {
  @override
  final int typeId = 11;

  @override
  LaunchTabBehavior read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LaunchTabBehavior.resumeLastBook;
      case 1:
        return LaunchTabBehavior.alwaysLibrary;
      default:
        return LaunchTabBehavior.resumeLastBook;
    }
  }

  @override
  void write(BinaryWriter writer, LaunchTabBehavior obj) {
    switch (obj) {
      case LaunchTabBehavior.resumeLastBook:
        writer.writeByte(0);
        break;
      case LaunchTabBehavior.alwaysLibrary:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaunchTabBehaviorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MiddleClickTabBehaviorAdapter
    extends TypeAdapter<MiddleClickTabBehavior> {
  @override
  final int typeId = 12;

  @override
  MiddleClickTabBehavior read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MiddleClickTabBehavior.switchToNewTab;
      case 1:
        return MiddleClickTabBehavior.stayOnCurrentTab;
      default:
        return MiddleClickTabBehavior.switchToNewTab;
    }
  }

  @override
  void write(BinaryWriter writer, MiddleClickTabBehavior obj) {
    switch (obj) {
      case MiddleClickTabBehavior.switchToNewTab:
        writer.writeByte(0);
        break;
      case MiddleClickTabBehavior.stayOnCurrentTab:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiddleClickTabBehaviorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScreenOrientationLockAdapter extends TypeAdapter<ScreenOrientationLock> {
  @override
  final int typeId = 13;

  @override
  ScreenOrientationLock read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScreenOrientationLock.portraitUp;
      case 1:
        return ScreenOrientationLock.landscapeLeft;
      case 2:
        return ScreenOrientationLock.landscapeRight;
      case 3:
        return ScreenOrientationLock.portraitDown;
      default:
        return ScreenOrientationLock.portraitUp;
    }
  }

  @override
  void write(BinaryWriter writer, ScreenOrientationLock obj) {
    switch (obj) {
      case ScreenOrientationLock.portraitUp:
        writer.writeByte(0);
        break;
      case ScreenOrientationLock.landscapeLeft:
        writer.writeByte(1);
        break;
      case ScreenOrientationLock.landscapeRight:
        writer.writeByte(2);
        break;
      case ScreenOrientationLock.portraitDown:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenOrientationLockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SettingsFavoritesOpenModeAdapter
    extends TypeAdapter<SettingsFavoritesOpenMode> {
  @override
  final int typeId = 14;

  @override
  SettingsFavoritesOpenMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SettingsFavoritesOpenMode.newTab;
      case 1:
        return SettingsFavoritesOpenMode.toggleInPlace;
      default:
        return SettingsFavoritesOpenMode.newTab;
    }
  }

  @override
  void write(BinaryWriter writer, SettingsFavoritesOpenMode obj) {
    switch (obj) {
      case SettingsFavoritesOpenMode.newTab:
        writer.writeByte(0);
        break;
      case SettingsFavoritesOpenMode.toggleInPlace:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsFavoritesOpenModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
