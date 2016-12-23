#
# release.sh
# copied from luatexja project and adapted

PROJECT=jfontmaps
DIR=`pwd`/..
VER=${VER:-`date +%Y%m%d.0`}

TEMP=`mktemp -d`

echo "Making Release $VER. Ctrl-C to cancel."
read REPLY
if test -d "$TEMP/$PROJECT-$VER"; then
  echo "Warning: the directory '$TEMP/$PROJECT-$VER' is found:"
  echo
  ls $TEMP/$PROJECT-$VER
  echo
  echo -n "I'm going to remove this directory. Continue? yes/No"
  echo
  read REPLY <&2
  case $REPLY in
    y*|Y*) rm -rf $TEMP/$PROJECT-$VER;;
    *) echo "Aborted."; exit 1;;
  esac
fi
echo
git commit -m "Release $VER" --allow-empty
git archive --format=tar --prefix=$PROJECT-$VER/ HEAD | (cd $TEMP && tar xf -)
git --no-pager log --date=short --format='%ad  %aN  <%ae>%n%n%x09* %s%d [%h]%n' > $TEMP/$PROJECT-$VER/ChangeLog
cat ChangeLog.pre-git >> $TEMP/$PROJECT-$VER/ChangeLog
cd $TEMP
rm -rf $PROJECT-$VER-orig
cp -r $PROJECT-$VER $PROJECT-$VER-orig
cd $PROJECT-$VER
rm -f .gitignore
for i in README script/kanji-fontmap-creator.pl script/kanji-config-updmap.pl ; do
  perl -pi.bak -e "s/\\\$VER\\\$/$VER/g" $i
  rm -f ${i}.bak
done
cd ..
diff -urN $PROJECT-$VER-orig $PROJECT-$VER

#
# separate free and nonfree packages
mkdir $PROJECT-nonfree-$VER
# remove the non-free part in the main project
for i in $PROJECT-$VER/maps/* ; do
  bn=`basename $i`
  case $bn in
    # -- Japanese nonfree fonts
    # -- currently we don't want to separate Japanese nonfree fonts !
    # hiragino|hiragino-pron|hiragino-elcapitan|hiragino-elcapitan-pron) 
    #   mv $PROJECT-$VER/maps/$bn $PROJECT-nonfree-$VER ;;
    # kozuka|kozuka-pr6|kozuka-pr6n)
    #   mv $PROJECT-$VER/maps/$bn $PROJECT-nonfree-$VER ;;
    # morisawa|morisawa-pr6n)
    #   mv $PROJECT-$VER/maps/$bn $PROJECT-nonfree-$VER ;;
    # ms|ms-osx|yu-win|yu-win10|yu-osx)
    #   mv $PROJECT-$VER/maps/$bn $PROJECT-nonfree-$VER ;;
    # canon|toppanbunkyu-sierra)
    #   mv $PROJECT-$VER/maps/$bn $PROJECT-nonfree-$VER ;;
    # -- Chinese/Korean nonfree fonts
    adobe|apple|dynacomware|sinotype)
      mv $PROJECT-$VER/maps/$bn $PROJECT-nonfree-$VER ;;
  esac
done
# remove the rest of the stuff
mv $PROJECT-$VER/README.nonfree $PROJECT-nonfree-$VER/README

tar zcf $DIR/$PROJECT-$VER.tar.gz $PROJECT-$VER
tar zcf $DIR/$PROJECT-nonfree-$VER.tar.gz $PROJECT-nonfree-$VER
echo
echo You should execute
echo
echo "  git push && git tag $VER && git push origin $VER"
echo
echo Informations for submitting CTAN: 
echo "  CONTRIBUTION: jfontmaps"
echo "  SUMMARY:      Font maps and configuration tools for Japanese fonts"
echo "  DIRECTORY:    language/japanese/jfontmaps"
echo "  LICENSE:      free/other-free"
echo "  FILE:         $DIR/$PROJECT-$VER.tar.gz"
echo ""
echo "  CONTRIBUTION: jfontmaps-nonfree"
echo "  SUMMARY:      Font maps for non-free Japanese fonts (companion to jfontmaps)"
echo "  DIRECTORY:    language/japanese/jfontmaps-nonfree"
echo "  LICENSE:      free/other-free"
echo "  FILE:         $DIR/$PROJECT-nonfree-$VER.tar.gz"


