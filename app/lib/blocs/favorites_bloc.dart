import "package:shared_preferences/shared_preferences.dart";

import "../timeline/timeline_entry.dart";
import "../search_manager.dart";

class FavoritesBloc
{
    static const String FAVORITES_KEY = "Favorites";
    final List<TimelineEntry> _favorites = [];

    FavoritesBloc()
    {
        _init();
    }

    _init() async
    {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> favs = prefs.getStringList(FavoritesBloc.FAVORITES_KEY);
        if(favs != null)
        {
            SearchManager sm = SearchManager.init();
            _favorites.clear();
            for(String f in favs)
            {
                Set<TimelineEntry> entries = sm.performSearch(f.toLowerCase());
                if(entries.length == 1)
                {
                    this._favorites.add(entries.first);
                }
            }
        }
    }

    Future<List<TimelineEntry>> fetchFavorites()
    {
        return SharedPreferences.getInstance().then(
            (SharedPreferences prefs) {
                List<TimelineEntry> res = [];
                List<String> favs = prefs.getStringList(FAVORITES_KEY) ?? [];
                SearchManager sm = SearchManager.init();

                for(String f in favs)
                {
                    Set<TimelineEntry> entries = sm.performSearch(f.toLowerCase());
                    if(entries.length == 1)
                    {
                        res.add(entries.first);
                    }    
                }
                return res;
            }
        );
    }

    List<TimelineEntry> get favorites
    {
        return _favorites;
    }

    addFavorite(TimelineEntry e)
    {
        if(!_favorites.contains(e))
        {
            this._favorites.add(e);
            _save();
        }
    }

    removeFavorite(TimelineEntry e)
    {
        if(_favorites.contains(e))
        {
            this._favorites.remove(e);
            _save();
        }
    }

    _save()
    {
        SharedPreferences.getInstance().then(
            (SharedPreferences prefs)
            {
                List<String> favsList = _favorites.map((TimelineEntry en) => en.label).toList();
                print("SAVING THIS LIST: $favsList");
                prefs.setStringList(FavoritesBloc.FAVORITES_KEY, favsList);
            }
        );
    }
}