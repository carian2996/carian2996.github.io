---
layout: post
title:  "Publish your Analysis in a Blog"
date:   2017-02-19 11:10
---

This work is based on [Jon Zelner's blog](http://www.jonzelner.net/jekyll/knitr/r/2014/07/02/autogen-knitr/).

Sharing your analysis can be an excellent way to learn from others (from commentaries, suggestions and critics) and also collaborate with your discoveries. One simple way to do that is publish on a personal blog and share it with your friends.

In this entry you will learn how to:

1. Create a personal web page to store your papers.
2. Manage and personalize your blog page.
3. Automate your analysis (RMarkdown) to publish it.

Let's start!

<br>

--------
## 1. Create a personal web page
Nowadays create a web page can be really easy. We will work with [Github](https://github.com/), that works as host, and there we will deploy our blog. 

The first thing to do is create an account on Github. You can learn more about Github [here](https://techcrunch.com/2012/07/14/what-exactly-is-github-anyway/) and after that, maybe some reading about the Github's core, a really cool project call [Git](https://git-scm.com/).

<br>
![signup]({{ site.url }}/assets/signup-githup.png){: .center-image height="250px" width="250px"}
<br>

**Tip: Choose wisely your username, it will be part of the URL for your blog**. Once you have signed and created an account you will need to create a new repository and convert it into your new web page. Simply navigate into your repositories and create a new one:

<br>
![new-repo]({{ site.url }}/assets/new-repo.png){: .center-image}
<br>

**You should name the new repository like this: username.github.io**. This will be the URL direction for your page: `http://username.github.io`. Finally create a new file called `index.html` with the following sentence `<h1>Hello world!</h1>`.

<br>
![index]({{ site.url }}/assets/index.png){: .center-image}
<br>

Add a nice description for the change in your repository and commit it. 

<br>
![commit]({{ site.url }}/assets/commit.png){: .center-image}
<br>

Why should we did all those steps? You can find how Git works in [this](https://try.github.io/levels/1/challenges/1) nice tutorial. Of course, learn how Git and Github work also will help you to gain a valuable skill for the future.

So, that's all! You can put `http://username.github.io.` in your browser and admire your creation!

<br>

--------
## 2. Personalize your blog.
To get started, we should work locally before upload our changes. To do that we need to clone our repository hosted in Github. You can learn more about cloning repositories [here](https://help.github.com/articles/cloning-a-repository/). You can use [Gitkraken](https://www.gitkraken.com/) (a nice GUI for managing your Github repositories). Once you have cloned (or just downloaded) the repository, your local folder should look like this:

<br>
![local]({{ site.url }}/assets/local.png){: .center-image}
<br>

Now you can find a theme for your blog and put it into your folder. Search [here](http://google.com/#q=jekyll+themes) for cool themes. We will use the basic theme [Poole](https://github.com/poole/poole). Again, clone or download the Poole repository into your blog folder, it should looks like this (with a bunch of strange folders) and an important file called `_config.yml`:

<br>
![poole]({{ site.url }}/assets/poole.png){: .center-image}
<br>

You can start changing this `_config.yml file to set your blog title, author name, social media and [more](http://jekyllrb.com/docs/configuration/). But, how can I see my changes before deploying them into Github? Well, if you want to see locally your page, you will need to install the following dependencies:

1. [Ruby](https://www.ruby-lang.org/es/) (The programming language used).
2. [Gems](https://rubygems.org/) (Ruby community’s gem hosting service. Gem == package).
3. [Jekyll](https://jekyllrb.com/) (Jekyll is a simple, blog-aware, static site generator).

If you have read until here, you should be able to run the **Jekyll** server and view your blog locally on `localhost:4000`. Simply use the following sentences to run the blog:

```bash
cd your/path/to/blog
jekyll server
```

And that is how (locally) your blog should looks like: 

<br>
![local-blog]({{ site.url }}/assets/local-blog.png){: .center-image}
<br>

**Tip: Don't forget to set** `url: "https://username.github.io"` **in your** `_config.yml` **file to properly establish your root.**

The only folder you need to modify in order to publish your reports is the `./_posts/` folder. Here, every markdown document would be consider as a entry in your blog. For example if you create a markdown file called `2017-02-19-welcome.markdown` and inside you write: 

```markdown
---
layout: post
title: "Welcome!"
date: 2017-02-19 12:00
---

Hello, this is my blog. 
```

You should be able to see the new entry like this:

<br>
![new-post]({{ site.url }}/assets/new-post.png){: .center-image}
<br>

Lets deploy this simple entry. [Commit](https://try.github.io/levels/1/challenges/8) and [push](https://try.github.io/levels/1/challenges/11) your changes into Github (use Gitkraken to simplify those steps) and then you can go to `https://yourusername.github.io/2017/02/19/welcome/` to see your first post.

**Tip: If you have experience with HTML and CSS or YMAL use it for customize your blog**. More info [here](https://jekyllrb.com/docs/frontmatter/) and [here](https://webdesign.tutsplus.com/tutorials/how-to-set-up-a-jekyll-theme--cms-26332).

<br>

--------
## 3. Automate your publishing.

Alright, now we have our blog settled, we can automate our publishing process with Rmarkdown files. First we need to create a new file called `render_post.R` (it should be located in the blog's root folder):

<br>
{% gist carian2996/a04c113cd13571689d42333dad55c755 %}
<br>

The previous function will take the `Rmd` file containing the analysis, it will run the file with R and will generate the possible outcomes (like images, tables or something else) to store them in a specific folder and finally, will put a `markdown` file in the `_post` folder. 

**Tip: In your Rmarkdown only set the title and date and one parameter `layout:` as `post`.**

Use the RStudio's example Rmarkdown file to test the function. First, open RStudio and create a new Rmarkdown. You can allocate your analysis in a folder named `_knitr`. Your blog's structure should look like this:

<br>
![test-rmd]({{ site.url }}/assets/test-rmd.png){: .center-image width="250px"}
<br>

Finally, you need to be able to run the `render_post.R` as a function in you computer, use the following command to do that:

```shell
cd /your/that/to/blog
sudo chmod +x render_post.R
```

After this, you need to run the R function with your `test.Rmd`. Move into you `_knitr` folder and run with the next command:

```shell
cd _knitr
Rscript ../render_post.R test.Rmd
```

Now your Rmarkdown is on your blog! Some files should be added like this:

<br>
![render]({{ site.url }}/assets/render.png){: .center-image width="250px"}
<br>

--------

<br>
![render2]({{ site.url }}/assets/render2.png){: .center-image}
<br>

**Tip: Remember that your are working locally... The last step is commit your changes with git and push them into your remote repository (on Github), once you will do that, you can go to `https://username.github.io` and check your great work :)**

Congrats! Now you can work with your Rmarkdown files and just copy those files into your `_knitr` folder and run again the magic function. Have fun!