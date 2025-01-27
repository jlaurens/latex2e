#!/usr/bin/env texlua

-- Build script for LaTeX2e files

--  No bundle or module here, but these have to be defined
bundle  = "LaTeX2e"
module  = ""

-- List of bundles ordered by 'importance'
bundles  = {
  "base",
  "required/cyrillic",
  "required/graphics",
  "required/tools",
  "required/amsmath",
  "required/firstaid"
}

-- Location of main directory: use Unix-style path separators
maindir = "."

-- Help for the master script is simple
function help ()
  print ""
  print " build check   - run automated check system       "
  print " build ctan    - create CTAN-ready archive        "
  print " build doc     - runs all documentation files     "
  print " build clean   - clean out directory tree         "
  print " build install - install files in local texmf tree"
  print ""
end

-- A custom main function
-- While almost all of this is customise, the need to be able to cp and
-- rm files means that loading l3build.lua is very useful
function main (target)
  local errorlevel
  local function dobundles (target)
    -- Avoid inter-bundle issues
    for _,v in ipairs(bundles) do
      if target == "ctan" then call({v},"clean") end
      local errorlevel = call({v},target)
      if errorlevel ~= 0 then return errorlevel end
    end
    return 0
  end
  if target == "check" then
    errorlevel = dobundles ("check")
  elseif target == "clean" then
    print ("Cleaning up")
    errorlevel = dobundles ("clean")
    rm (".", "*.zip")
  elseif target == "ctan" then
    errorlevel = dobundles ("ctan")
    if errorlevel == 0 then
      for _,i in ipairs (bundles) do
        cp ("*.zip", i, ".")
      end
    end
  elseif target == "doc" then
    errorlevel = dobundles ("doc")
  elseif target == "install" then
    errorlevel = dobundles ("install")
  elseif target == "tag" then
    errorlevel = dobundles("tag")
  elseif target == "uninstall" then
    errorlevel = dobundles("uninstall")
  elseif target == "unpack" then
    errorlevel = dobundles ("unpack")
  elseif target == "version" then
      version ()
  else
    help ()
  end
  if errorlevel ~=0 then
    os.exit(1)
  end
end

-- Find and run the build system
kpse.set_program_name ("kpsewhich")
dofile(("./build-config.lua"))
if not release_date then
  dofile(kpse.lookup("l3build.lua"))
end

