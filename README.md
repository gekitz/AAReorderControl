## AAReorderContentView:

AAReorderContentView gives you the possibility to drag&drop a view between different UITableViews. Just add AAReorderCell as cell in your UITableView.

Demo video available under [http://vimeo.com/35507673](http://vimeo.com/35507673) .

## Important Facts

- Both UITableViews **must** have the same superview.
- Both UITableViews must be visible with its complete content (scrolling inside a Tableview while dragging is not support at the moment).

## Setup

- Drag&Drop the AAReorderContentView folder into your project.
- Use AAReorderCell or a derived class of AAReorderCell as cell in your UITableView.

## Customization

You can set the following colors of the reorder view:
``` UIColor *titleColor; ```
``` UIColor *titleHighlightedColor; ```
``` UIColor *draggingPlaceholderColor; ```
``` UIColor *draggingHighlightedColor; ```
``` UIColor *draggingHighlightedBorderColor; ```

or you apply a ``` AAReorderDrawRect drawRect ``` block to your reorder view to apply custom drawing.

## Work In Progress

Right now I'm working on scrolling support for the TableViews while you are dragging the AAReorderContentView.

## Author

Georg Kitz
You can follow me on Twitter [@gekitz](http://www.twitter.com/gekitz).

## License 

This source code is available under MIT license. For details check the license file.


