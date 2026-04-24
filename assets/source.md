# 🧨 Markdown Extreme Format & Table Stress Test

This document focuses on the "difficult" parts of Markdown—specifically complex tables, manual line breaks, and recursive formatting.

---

## 1. The Multi-Line Table Challenge

Standard Markdown tables are row-based and do not support newlines. To achieve a "break" inside a cell, we must use `<br />` or HTML block elements.

| Feature | Method | Result / Preview |
| :--- | :--- | :--- |
| **Line Breaks** | Using `<br>` | First Line<br>Second Line<br>Third Line |
| **Paragraphs** | Using `p` tags | <p>Paragraph A</p><p>Paragraph B</p> |
| **Lists in Tables** | HTML `ul/li` | <ul><li>Point 1</li><li>Point 2</li></ul> |
| **Code in Tables** | Inline Backticks | `const x = 10;`<br>`console.log(x);` |

---

## 2. Nested HTML Table (The "Nuclear" Option)

If the standard pipe table (`|`) fails your layout needs, most advanced renderers support raw HTML tables. This allows for `rowspan` and `colspan`.

<table>
  <tr>
    <th>Category</th>
    <th>Nested Layout</th>
    <th>Notes</th>
  </tr>
  <tr>
    <td rowspan="2"><b>Complex Cell</b></td>
    <td>
      <ul>
        <li>Sub-item 1</li>
        <li>Sub-item 2</li>
      </ul>
    </td>
    <td>Using <code>rowspan</code> to span two rows.</td>
  </tr>
  <tr>
    <td>
      <pre><code>// Block inside table
function test() {
  return true;
}</code></pre>
    </td>
    <td>Standard Markdown usually breaks here.</td>
  </tr>
</table>

---

## 3. Deep Linking & Invisible Anchors

Testing internal navigation via IDs.

- [Jump to Footnote Test](#footnote-anchor)
- [Jump to Top](#top-of-page) <a name="top-of-page"></a>

---

## 4. Line Break Stress Test

### Hard Breaks vs. Soft Breaks
This is a line. (No trailing spaces)
This is the next line in the source, but should render on the same line in HTML.

This is a line with two spaces at the end.  
This should appear on a new line (Hard Break).

Using the HTML break tag<br>This should also be on a new line.

---

## 5. Admonitions & Nested Quotes (GFM)

> [!CAUTION]
> **Nested Complexity Test**
> > This is a nested quote inside a Caution block.
> > 1. It contains a list.
> > 2. And a `code snippet`.

---

## 6. Definition Lists (Extended Syntax)

Term 1
:   This is the definition of Term 1.
:   Definitions can have multiple paragraphs.
    
    This is the second paragraph of the definition for Term 1.

Term 2
:   Definition with code: `print("Hello")`

---

## 7. Math & Symbol Overload

Testing if symbols inside tables break the parser.

| Math | Logic | Entities |
| :--- | :--- | :--- |
| $x_{n+1} = \frac{x_n}{2}$ | $A \implies B$ | &copy; &reg; &trade; &plusmn; |
| $\sum_{i=1}^{\infty} \frac{1}{n^2}$ | $\forall x \in \mathbb{R}$ | &#128512; (Unicode) |

---

## 8. Footnotes & Back-references <a name="footnote-anchor"></a>

The placement of this footnote should be at the very bottom of the rendered page, regardless of where it is defined in the source[^table_fn].

[^table_fn]: **Footnote success!** This footnote includes a **bold statement** and verifies that the anchor link from Section 3 works correctly.

---

## 9. Final Edge Case: The "Fenced" Code Block inside a List
1. Step one
2. Step two:
    ```javascript
    // Ensure the indentation of this block 
    // doesn't break the list numbering.
    function render() {
      return "Indented Block";
    }
    ```
3. Step three (Should still be numbered '3')