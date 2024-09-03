# Ajouter le type PresentationFramework pour WPF
Add-Type -AssemblyName PresentationCore,PresentationFramework


$filePath = ".\config.txt"
$global:content = Get-Content $filePath -Encoding UTF8

$global:data = @{}
$fList = @()
$global:langue = $null  # Variable pour stocker la langue
$global:erreurmaj = $null
$global:erreurtitre = $null
$global:closedWithX = $false

function Load-Data {
    param (
        [char]$startChar  # Le caractère choisi pour filtrer les lignes
    )

     $global:fList = @()

    foreach ($line in $global:content) {
        if ($line -notmatch '^\s*#') {  # Ignorer les lignes commentées
            if ($line.StartsWith("Langue=")) {
                $parts = $line -split '='

                if ($parts.Length -eq 2) {  # Vérifier que la ligne est bien formatée
                    $global:langue = $parts[1].Trim()  # Attribuer la valeur à la variable $langue
                }
            }
            elseif ($line.StartsWith("$startChar=")) {
                $parts = $line -split '='
                if ($startChar -eq 'I') {
                    if ($parts.Length -eq 4) {  # Vérifier que la ligne contient bien 4 parties après le découpage
                        $ingredient = $parts[1].Trim()  # La première partie après "I="
                        $value = $parts[2].Trim()       # La deuxième partie après "I="
                        $unit = $parts[3].Trim()        # La troisième partie après "I="
                        $global:data[$ingredient] = @{ Value = $value; Unit = $unit }
                    }
                }
                
                
            }
        }
    }

}

function Load-Favorites {
    $fileContent = Get-Content -Path $filePath
    
    foreach ($line in $fileContent) {
        if ($line -match '^F\d+=') {
            $parts = $line -split '='
            $variableName = $parts[0].Trim()
            $variableValue = $parts[1].Trim()
            Set-Variable -Name $variableName -Value $variableValue -Scope Global
        }
    }
}

function Update-Favorite {
    param (
        [int]$favoriteIndex,   # Le numéro du favori à mettre à jour (1, 2, 3, ...)
        [string]$ingredient    # L'ingrédient sélectionné dans la combobox
    )
    $fileContent = Get-Content -Path $filePath

    $favoriteLine = "F$favoriteIndex="

    for ($i = 0; $i -lt $fileContent.Count; $i++) {
        if ($fileContent[$i] -match "^$favoriteLine") {
            $fileContent[$i] = "$favoriteLine$ingredient"
            break
        }
    }

    # Sauvegarder le fichier avec les changements
    Set-Content -Path $filePath -Value $fileContent -Encoding UTF8

    # Mettre à jour la variable en mémoire également
    Set-Variable -Name "f$favoriteIndex" -Value $ingredient -Scope Global
}

function messfavok {
$global:title = "$global:confirmation"
Show-CustomMessageBox "$selectedIngredient $global:messagefavorisajout"
}

function messfavno {
$global:title = "$global:avertissement"
Show-CustomMessageBox "$global:messagefavoris"
}
Load-Data -startChar 'I'
Load-Favorites

$global:monnaie = "€"

# Création de la fenêtre
$mainWindow = New-Object Windows.Window
$mainWindow.Title = "CalCook 1.0"
$mainWindow.Width = 776
$mainWindow.Height = 490
$mainWindow.ResizeMode = 'NoResize'

# Création du Canvas pour le positionnement absolu
$canvas = New-Object System.Windows.Controls.Canvas


#region image de fond
#$imagePath = "C:\Users\sfran\Downloads\FIREFOX\flags-france.jpg"  # Remplacez par le chemin de votre image
#$imageBrush = New-Object Windows.Media.ImageBrush
#$image = New-Object Windows.Media.Imaging.BitmapImage
#$image.BeginInit()
#$image.UriSource = New-Object Uri($imagePath, [UriKind]::Absolute)
#$image.EndInit()
#$imageBrush.ImageSource = $image
#endregion

#region image langue
$flagfr = ".\Flags\fr.png"
$flaggb = ".\Flags\gb.png"    
$flages = ".\Flags\es.png"
$flagde = ".\Flags\de.png"
$flagus = ".\Flags\us.png"
$flagit = ".\Flags\it.png"
#endregion

# Assigner l'ImageBrush comme fond du Canvas
$canvas.Background = $imageBrush

#region favoris
$fav1 = New-Object System.Windows.Controls.Button
$fav1.Content = "❤️"
$fav1.Width = 26
$fav1.Height = 26
$fav1.FontSize = 15
$fav1.HorizontalAlignment = 'Center'
$fav1.VerticalAlignment = 'Top'
$fav1.VerticalContentAlignment = 'Center'
$fav1.Margin = [System.Windows.Thickness]::new(10, 40, 0, 0)

$tooltipfav = New-Object System.Windows.Controls.ToolTip
$tooltipfav.Content = ""
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav1, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav1, 3000)     # Durée d'affichage en millisecondes
$fav1.ToolTip = $tooltipfav

$fav1.Add_Click({
    if ($i1comboBox.SelectedItem) {
        $selectedIngredient = $i1comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 1 -ingredient $selectedIngredient
        messfavok
    } else {
        messfavno
    }
})

$fav2 = New-Object System.Windows.Controls.Button
$fav2.Content = "❤️"
$fav2.Width = 26
$fav2.Height = 26
$fav2.FontSize = 15
$fav2.HorizontalAlignment = 'Center'
$fav2.VerticalAlignment = 'Top'
$fav2.VerticalContentAlignment = 'Center'
$fav2.Margin = [System.Windows.Thickness]::new(10, 80, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav2, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav2, 3000)     # Durée d'affichage en millisecondes
$fav2.ToolTip = $tooltipfav

$fav2.Add_Click({
    if ($i2comboBox.SelectedItem) {
        $selectedIngredient = $i2comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 2 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav3 = New-Object System.Windows.Controls.Button
$fav3.Content = "❤️"
$fav3.Width = 26
$fav3.Height = 26
$fav3.FontSize = 15
$fav3.HorizontalAlignment = 'Center'
$fav3.VerticalAlignment = 'Top'
$fav3.VerticalContentAlignment = 'Center'
$fav3.Margin = [System.Windows.Thickness]::new(10, 120, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav3, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav3, 3000)     # Durée d'affichage en millisecondes
$fav3.ToolTip = $tooltipfav

$fav3.Add_Click({
    if ($i3comboBox.SelectedItem) {
        $selectedIngredient = $i3comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 3 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav4 = New-Object System.Windows.Controls.Button
$fav4.Content = "❤️"
$fav4.Width = 26
$fav4.Height = 26
$fav4.FontSize = 15
$fav4.HorizontalAlignment = 'Center'
$fav4.VerticalAlignment = 'Top'
$fav4.VerticalContentAlignment = 'Center'
$fav4.Margin = [System.Windows.Thickness]::new(10, 160, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav4, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav4, 3000)     # Durée d'affichage en millisecondes
$fav4.ToolTip = $tooltipfav

$fav4.Add_Click({
    if ($i4comboBox.SelectedItem) {
        $selectedIngredient = $i4comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 4 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav5 = New-Object System.Windows.Controls.Button
$fav5.Content = "❤️"
$fav5.Width = 26
$fav5.Height = 26
$fav5.FontSize = 15
$fav5.HorizontalAlignment = 'Center'
$fav5.VerticalAlignment = 'Top'
$fav5.VerticalContentAlignment = 'Center'
$fav5.Margin = [System.Windows.Thickness]::new(10, 200, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav5, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav5, 3000)     # Durée d'affichage en millisecondes
$fav5.ToolTip = $tooltipfav

$fav5.Add_Click({
    if ($i5comboBox.SelectedItem) {
        $selectedIngredient = $i5comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 5 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav6 = New-Object System.Windows.Controls.Button
$fav6.Content = "❤️"
$fav6.Width = 26
$fav6.Height = 26
$fav6.FontSize = 15
$fav6.HorizontalAlignment = 'Center'
$fav6.VerticalAlignment = 'Top'
$fav6.VerticalContentAlignment = 'Center'
$fav6.Margin = [System.Windows.Thickness]::new(10, 240, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav6, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav6, 3000)     # Durée d'affichage en millisecondes
$fav6.ToolTip = $tooltipfav

$fav6.Add_Click({
    if ($i6comboBox.SelectedItem) {
        $selectedIngredient = $i6comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 6 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav7 = New-Object System.Windows.Controls.Button
$fav7.Content = "❤️"
$fav7.Width = 26
$fav7.Height = 26
$fav7.FontSize = 15
$fav7.HorizontalAlignment = 'Center'
$fav7.VerticalAlignment = 'Top'
$fav7.VerticalContentAlignment = 'Center'
$fav7.Margin = [System.Windows.Thickness]::new(10, 280, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav7, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav7, 3000)     # Durée d'affichage en millisecondes
$fav7.ToolTip = $tooltipfav

$fav7.Add_Click({
    if ($i7comboBox.SelectedItem) {
        $selectedIngredient = $i7comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 7 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav8 = New-Object System.Windows.Controls.Button
$fav8.Content = "❤️"
$fav8.Width = 26
$fav8.Height = 26
$fav8.FontSize = 15
$fav8.HorizontalAlignment = 'Center'
$fav8.VerticalAlignment = 'Top'
$fav8.VerticalContentAlignment = 'Center'
$fav8.Margin = [System.Windows.Thickness]::new(10, 320, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav8, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav8, 3000)     # Durée d'affichage en millisecondes
$fav8.ToolTip = $tooltipfav

$fav8.Add_Click({
    if ($i8comboBox.SelectedItem) {
        $selectedIngredient = $i8comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 8 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav9 = New-Object System.Windows.Controls.Button
$fav9.Content = "❤️"
$fav9.Width = 26
$fav9.Height = 26
$fav9.FontSize = 15
$fav9.HorizontalAlignment = 'Center'
$fav9.VerticalAlignment = 'Top'
$fav9.VerticalContentAlignment = 'Center'
$fav9.Margin = [System.Windows.Thickness]::new(10, 360, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav9, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav9, 3000)     # Durée d'affichage en millisecondes
$fav9.ToolTip = $tooltipfav

$fav9.Add_Click({
    if ($i9comboBox.SelectedItem) {
        $selectedIngredient = $i9comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 9 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})

$fav10 = New-Object System.Windows.Controls.Button
$fav10.Content = "❤️"
$fav10.Width = 26
$fav10.Height = 26
$fav10.FontSize = 15
$fav10.HorizontalAlignment = 'Center'
$fav10.VerticalAlignment = 'Top'
$fav10.VerticalContentAlignment = 'Center'
$fav10.Margin = [System.Windows.Thickness]::new(10, 400, 0, 0)

[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($fav10, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($fav10, 3000)     # Durée d'affichage en millisecondes
$fav10.ToolTip = $tooltipfav

$fav10.Add_Click({
    if ($i10comboBox.SelectedItem) {
        $selectedIngredient = $i10comboBox.SelectedItem.ToString()
        Update-Favorite -favoriteIndex 10 -ingredient $selectedIngredient
         messfavok
    } else {
        messfavno
    }
})
#endregion

#region listes ingrédients
function Show-UnitInputDialog {
    param (
        [string]$ingredient
    )
    $global:closedWithX = $false
    $global:buttonClicked = $false

    # Création de la fenêtre
    $window = New-Object System.Windows.Window
    $window.Title = "$global:titreunite"
    $window.SizeToContent = "WidthAndHeight"
    $window.ResizeMode = "NoResize"
    $window.FontSize = 14  # Augmenter la taille de la police pour l'ensemble de la fenêtre

    $window.WindowStartupLocation = "Manual" # On va manuellement définir la position

    # Grid pour organiser les contrôles
    $grid = New-Object System.Windows.Controls.Grid
    $grid.Margin = "10"
    $window.Content = $grid

    # Création des lignes
    for ($i = 0; $i -lt 3; $i++) {  # Ajout d'une troisième ligne
        $row = New-Object System.Windows.Controls.RowDefinition
        $grid.RowDefinitions.Add($row)
    }

    # Label pour l'instruction
    $label = New-Object System.Windows.Controls.Label
    $label.Content = "$global:titreunite '$ingredient' :"
    $label.Margin = "5"
    $label.FontSize = 14  # Augmenter la taille de la police pour le label
    $label.Foreground = [System.Windows.Media.Brushes]::Red
    [void]$label.SetValue([System.Windows.Controls.Grid]::RowProperty, 0)
    $grid.Children.Add($label)

    # TextBox pour entrer l'unité
    $textBox = New-Object System.Windows.Controls.TextBox
    $textBox.Margin = "5"
    $textBox.Width = 150  # Ajustement de la largeur de la TextBox
    $textBox.HorizontalAlignment = 'Center'  # Centrage de la TextBox
    $textBox.FontSize = 14  # Augmenter la taille de la police pour la TextBox
    [void]$textBox.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
    $grid.Children.Add($textBox)

    # Bouton OK pour confirmer la saisie
    $okButton = New-Object System.Windows.Controls.Button
    $okButton.Content = "OK"
    $okButton.Margin = "5"
    $okButton.HorizontalAlignment = 'Center'  # Centrage du bouton OK
    $okButton.FontSize = 14  # Augmenter la taille de la police pour le bouton OK
    [void]$okButton.SetValue([System.Windows.Controls.Grid]::RowProperty, 2)  # Positionner le bouton sur la troisième ligne
    $okButton.IsEnabled = $false  # Initialement désactiver le bouton OK
    $okButton.Add_Click({
        $global:unite = $textBox.Text  # Stocker le texte saisi dans la variable globale
        $global:buttonClicked = $true
        $window.Close()
    })
    $grid.Children.Add($okButton)

    # Ajouter un gestionnaire d'événements pour la TextBox
    $textBox.Add_TextChanged({
        # Activer ou désactiver le bouton OK en fonction du texte dans la TextBox
        if ($textBox.Text.Trim()) {
            $okButton.IsEnabled = $true
        } else {
            $okButton.IsEnabled = $false
        }
    })

        $window.Add_Loaded({
        $window.Left = $mainWindow.Left + ($mainWindow.Width - $window.ActualWidth) / 2
        $window.Top = $mainWindow.Top + ($mainWindow.Height - $window.ActualHeight) / 2
    })

        # Ajouter un événement pour détecter la fermeture de la fenêtre
    $window.Add_Closing({
        param($sender, $e)

        if ($global:buttonClicked -eq $false) {
            # Si le bouton OK n'a pas été cliqué, on suppose que la fenêtre a été fermée par la croix
            $global:closedWithX = $true
        } else {
            $global:closedWithX = $false
        }
    })


    # Affiche la fenêtre et attend la fermeture
    $window.ShowDialog()

    # Retourne l'unité saisie
    return $global:unite
}

function Show-CustomMessageBox {
    param (
        [string]$message,
        [string]$title = "Message"
    )

    # Création de la fenêtre
    $window = New-Object System.Windows.Window
    $window.Title = $global:title
    $window.SizeToContent = "WidthAndHeight"

    $window.ResizeMode = "NoResize"
    $window.FontSize = 14  # Taille de police plus grande

    # Grid pour organiser les contrôles
    $grid = New-Object System.Windows.Controls.Grid
    $grid.Margin = "20"
    $window.Content = $grid

        $window.Add_Loaded({
        $music = "$env:windir\Media\Windows Notify Messaging.wav"

        if (Test-Path $music){
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Notify Messaging.wav").Play()}
        else{        
        [System.Media.SystemSounds]::Asterisk.Play()
        }

        $window.Left = $mainWindow.Left + ($mainWindow.Width - $window.ActualWidth) / 2
        $window.Top = $mainWindow.Top + ($mainWindow.Height - $window.ActualHeight) / 2
    })

    # Création des lignes
    for ($i = 0; $i -lt 2; $i++) {  # Deux lignes : une pour le texte, une pour le bouton
        $row = New-Object System.Windows.Controls.RowDefinition
        $grid.RowDefinitions.Add($row)
    }

    # Label pour afficher le message
    $label = New-Object System.Windows.Controls.Label
    $label.Content = $message
    $label.Margin = "10"
    $label.HorizontalAlignment = 'Center'
    $label.VerticalAlignment = 'Center'
    [void]$label.SetValue([System.Windows.Controls.Grid]::RowProperty, 0)
    $grid.Children.Add($label)


    # Bouton OK pour fermer la fenêtre
    $okButton = New-Object System.Windows.Controls.Button
    $okButton.Content = "OK"
    $okButton.Margin = "10"
    $okButton.Width = 75
    $okButton.HorizontalAlignment = 'Center'  # Centrer le bouton OK
    [void]$okButton.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
    $okButton.Add_Click({
        $window.Close()
    })
    $grid.Children.Add($okButton)

    # Affiche la fenêtre et attend la fermeture
    $window.ShowDialog()
}

function Update-OrAddIngredient {
    param (
        [string]$ingredient,
        [string]$price
    )

    $found = $false
    $updatedContent = @()
    $ingredientSectionEndIndex = -1

    for ($i = 0; $i -lt $global:content.Length; $i++) {
        $line = $global:content[$i]
        
        # Vérifier si la ligne correspond à l'ingrédient
        if ($line -match "I=$ingredient=") {
            $found = $true
            $updatedContent += "I=$ingredient=$price=$($global:data[$ingredient].Unit)"
        $global:unite = $($global:data[$ingredient].Unit)
        $global:monnaiedial = $($global:data[$ingredient].Unit)
        }
        else {
            $updatedContent += $line
        }

        # Déterminer la fin de la section des ingrédients
        if ($line -match "^I=") {
            $ingredientSectionEndIndex = $i
        }
    }


    if (-not $found) {
        # Demander l'unité à l'utilisateur
        $selectedUnit = Show-UnitInputDialog -ingredient $ingredient
        
        # Si l'utilisateur n'a pas annulé la sélection
        if ($selectedUnit) {
            # Ajouter la nouvelle ligne avec l'unité saisie
            $newIngredientLine = "I=$ingredient=$price=$global:unite"
            if ($ingredientSectionEndIndex -ge 0) {
                $updatedContent = $updatedContent[0..$ingredientSectionEndIndex] + $newIngredientLine + $updatedContent[($ingredientSectionEndIndex + 1)..($updatedContent.Count - 1)]
            $global:monnaiedial = $global:unite
            }
            else {
                $updatedContent += $newIngredientLine  # Si aucune section d'ingrédients n'est trouvée (cas improbable)
            }
    }
    else{return}
    }
    
    if ($global:closedWithX -eq $false){
    $action = if ($found) { "$global:actionmaj" } else { "$global:actionajout" }
    $global:title = "$global:confirmation"
    Set-Content -Path $filePath -Value $updatedContent -Encoding UTF8
    Show-CustomMessageBox -message "$global:message1 '$ingredient' $global:message2 $action $global:message3 $price $global:monnaie/$global:monnaiedial $global:message4." -title "$global:title"
    }else{
    $global:unite = "_"}
    
 

    # Mettre à jour les ComboBox
    $comboBoxes = @($i1comboBox, $i2comboBox, $i3comboBox, $i4comboBox, $i5comboBox, $i6comboBox, $i7comboBox, $i8comboBox, $i9comboBox, $i10comboBox)

    $global:data = @{}
    $global:content = Get-Content $filePath -Encoding UTF8
    $fList = @()

    Load-Data -startChar 'F'
    Load-Data -startChar 'I'

     foreach ($comboBox in $comboBoxes) {
     $currentSelection = $comboBox.SelectedItem
       $comboBox.Items.Clear()
        foreach ($ingredient in $data.Keys | Sort-Object) {
            $comboBox.Items.Add($ingredient)
            $comboBox.SelectedItem = $currentSelection
        }}

   
    
}


$maji1 = New-Object System.Windows.Controls.Button
$maji1.Content = "➕"
$maji1.Width = 26
$maji1.Height = 26
$maji1.FontSize = 15
$maji1.HorizontalAlignment = 'Center'
$maji1.VerticalAlignment = 'Top'
$maji1.VerticalContentAlignment = 'Center'
$maji1.Margin = [System.Windows.Thickness]::new(46, 40, 0, 0)

$tooltipmaji1 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji1.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji1, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji1, 3000)     # Durée d'affichage en millisecondes
$maji1.ToolTip = $tooltipmaji1

$i1comboBox = New-Object System.Windows.Controls.ComboBox
$i1comboBox.Width = 170
$i1comboBox.FontSize = 15
$i1comboBox.IsEditable = $true
$i1comboBox.Focusable = $true
$i1comboBox.Margin = [System.Windows.Thickness]::new($maji1.Margin.Left + $maji1.Width + 14, $maji1.Margin.Top, 0, 0)

$maji1.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i1comboBox.Text) -or [string]::IsNullOrWhiteSpace($i1prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i1comboBox.Text
        $price = $i1prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i1unit.Content = "$global:monnaie/" + $global:unite
        $i1qunit.Content = $global:unite
        $i1comboBox.SelectedItem = $ingredient
    }
    })

$maji2 = New-Object System.Windows.Controls.Button
$maji2.Content = "➕"
$maji2.Width = 26
$maji2.Height = 26
$maji2.FontSize = 15
$maji2.HorizontalAlignment = 'Center'
$maji2.VerticalAlignment = 'Top'
$maji2.VerticalContentAlignment = 'Center'
$maji2.Margin = [System.Windows.Thickness]::new(46, 80, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji2 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji2.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji2, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji2, 3000)     # Durée d'affichage en millisecondes
$maji2.ToolTip = $tooltipmaji2

$i2comboBox = New-Object System.Windows.Controls.ComboBox
$i2comboBox.Width = 170
$i2comboBox.FontSize = 15
$i2comboBox.IsEditable = $true
$i2comboBox.Focusable = $true
$i2comboBox.Margin = [System.Windows.Thickness]::new($maji2.Margin.Left + $maji2.Width + 14, $maji2.Margin.Top, 0, 0)

$maji2.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i2comboBox.Text) -or [string]::IsNullOrWhiteSpace($i2prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i2comboBox.Text
        $price = $i2prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i2unit.Content = "$global:monnaie/" + $global:unite
        $i2qunit.Content = $global:unite
        $i2comboBox.SelectedItem = $ingredient
    }
    })

$maji3 = New-Object System.Windows.Controls.Button
$maji3.Content = "➕"
$maji3.Width = 26
$maji3.Height = 26
$maji3.FontSize = 15
$maji3.HorizontalAlignment = 'Center'
$maji3.VerticalAlignment = 'Top'
$maji3.VerticalContentAlignment = 'Center'
$maji3.Margin = [System.Windows.Thickness]::new(46, 120, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji3 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji3.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji3, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji3, 3000)     # Durée d'affichage en millisecondes
$maji3.ToolTip = $tooltipmaji3

$i3comboBox = New-Object System.Windows.Controls.ComboBox
$i3comboBox.Width = 170
$i3comboBox.FontSize = 15
$i3comboBox.IsEditable = $true
$i3comboBox.Focusable = $true
$i3comboBox.Margin = [System.Windows.Thickness]::new($maji3.Margin.Left + $maji3.Width + 14, $maji3.Margin.Top, 0, 0)

$maji3.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i3comboBox.Text) -or [string]::IsNullOrWhiteSpace($i3prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i3comboBox.Text
        $price = $i3prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i3unit.Content = "$global:monnaie/" + $global:unite
        $i3qunit.Content = $global:unite
        $i3comboBox.SelectedItem = $ingredient
    }
    })

$maji4 = New-Object System.Windows.Controls.Button
$maji4.Content = "➕"
$maji4.Width = 26
$maji4.Height = 26
$maji4.FontSize = 15
$maji4.HorizontalAlignment = 'Center'
$maji4.VerticalAlignment = 'Top'
$maji4.VerticalContentAlignment = 'Center'
$maji4.Margin = [System.Windows.Thickness]::new(46, 160, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji4 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji4.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji4, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji4, 3000)     # Durée d'affichage en millisecondes
$maji4.ToolTip = $tooltipmaji4

$i4comboBox = New-Object System.Windows.Controls.ComboBox
$i4comboBox.Width = 170
$i4comboBox.FontSize = 15
$i4comboBox.IsEditable = $true
$i4comboBox.Focusable = $true
$i4comboBox.Margin = [System.Windows.Thickness]::new($maji4.Margin.Left + $maji4.Width + 14, $maji4.Margin.Top, 0, 0)

$maji4.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i4comboBox.Text) -or [string]::IsNullOrWhiteSpace($i4prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i4comboBox.Text
        $price = $i4prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i4unit.Content = "$global:monnaie/" + $global:unite
        $i4qunit.Content = $global:unite
        $i4comboBox.SelectedItem = $ingredient
    }
    })

$maji5 = New-Object System.Windows.Controls.Button
$maji5.Content = "➕"
$maji5.Width = 26
$maji5.Height = 26
$maji5.FontSize = 15
$maji5.HorizontalAlignment = 'Center'
$maji5.VerticalAlignment = 'Top'
$maji5.VerticalContentAlignment = 'Center'
$maji5.Margin = [System.Windows.Thickness]::new(46, 200, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji5 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji5.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji5, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji5, 3000)     # Durée d'affichage en millisecondes
$maji5.ToolTip = $tooltipmaji5

$i5comboBox = New-Object System.Windows.Controls.ComboBox
$i5comboBox.Width = 170
$i5comboBox.FontSize = 15
$i5comboBox.IsEditable = $true
$i5comboBox.Focusable = $true
$i5comboBox.Margin = [System.Windows.Thickness]::new($maji5.Margin.Left + $maji5.Width + 14, $maji5.Margin.Top, 0, 0)

$maji5.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i5comboBox.Text) -or [string]::IsNullOrWhiteSpace($i5prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i5comboBox.Text
        $price = $i5prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i5unit.Content = "$global:monnaie/" + $global:unite
        $i5qunit.Content = $global:unite
        $i5comboBox.SelectedItem = $ingredient
    }
    })

$maji6 = New-Object System.Windows.Controls.Button
$maji6.Content = "➕"
$maji6.Width = 26
$maji6.Height = 26
$maji6.FontSize = 15
$maji6.HorizontalAlignment = 'Center'
$maji6.VerticalAlignment = 'Top'
$maji6.VerticalContentAlignment = 'Center'
$maji6.Margin = [System.Windows.Thickness]::new(46, 240, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji6 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji6.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji6, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji6, 3000)     # Durée d'affichage en millisecondes
$maji6.ToolTip = $tooltipmaji6

$i6comboBox = New-Object System.Windows.Controls.ComboBox
$i6comboBox.Width = 170
$i6comboBox.FontSize = 15
$i6comboBox.IsEditable = $true
$i6comboBox.Focusable = $true
$i6comboBox.Margin = [System.Windows.Thickness]::new($maji6.Margin.Left + $maji6.Width + 14, $maji6.Margin.Top, 0, 0)

$maji6.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i6comboBox.Text) -or [string]::IsNullOrWhiteSpace($i6prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i6comboBox.Text
        $price = $i6prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i6unit.Content = "$global:monnaie/" + $global:unite
        $i6qunit.Content = $global:unite
        $i6comboBox.SelectedItem = $ingredient
    }
    })

$maji7 = New-Object System.Windows.Controls.Button
$maji7.Content = "➕"
$maji7.Width = 26
$maji7.Height = 26
$maji7.FontSize = 15
$maji7.HorizontalAlignment = 'Center'
$maji7.VerticalAlignment = 'Top'
$maji7.VerticalContentAlignment = 'Center'
$maji7.Margin = [System.Windows.Thickness]::new(46, 280, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji7 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji7.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji7, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji7, 3000)     # Durée d'affichage en millisecondes
$maji7.ToolTip = $tooltipmaji7

$i7comboBox = New-Object System.Windows.Controls.ComboBox
$i7comboBox.Width = 170
$i7comboBox.FontSize = 15
$i7comboBox.IsEditable = $true
$i7comboBox.Focusable = $true
$i7comboBox.Margin = [System.Windows.Thickness]::new($maji7.Margin.Left + $maji7.Width + 14, $maji7.Margin.Top, 0, 0)

$maji7.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i7comboBox.Text) -or [string]::IsNullOrWhiteSpace($i7prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i7comboBox.Text
        $price = $i7prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i7unit.Content = "$global:monnaie/" + $global:unite
        $i7qunit.Content = $global:unite
        $i7comboBox.SelectedItem = $ingredient
    }
    })

$maji8 = New-Object System.Windows.Controls.Button
$maji8.Content = "➕"
$maji8.Width = 26
$maji8.Height = 26
$maji8.FontSize = 15
$maji8.HorizontalAlignment = 'Center'
$maji8.VerticalAlignment = 'Top'
$maji8.VerticalContentAlignment = 'Center'
$maji8.Margin = [System.Windows.Thickness]::new(46, 320, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji8 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji8.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji8, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji8, 3000)     # Durée d'affichage en millisecondes
$maji8.ToolTip = $tooltipmaji8

$i8comboBox = New-Object System.Windows.Controls.ComboBox
$i8comboBox.Width = 170
$i8comboBox.FontSize = 15
$i8comboBox.IsEditable = $true
$i8comboBox.Focusable = $true
$i8comboBox.Margin = [System.Windows.Thickness]::new($maji8.Margin.Left + $maji8.Width + 14, $maji8.Margin.Top, 0, 0)

$maji8.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i8comboBox.Text) -or [string]::IsNullOrWhiteSpace($i8prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i8comboBox.Text
        $price = $i8prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i8unit.Content = "$global:monnaie/" + $global:unite
        $i8qunit.Content = $global:unite
        $i8comboBox.SelectedItem = $ingredient
    }
    })

$maji9 = New-Object System.Windows.Controls.Button
$maji9.Content = "➕"
$maji9.Width = 26
$maji9.Height = 26
$maji9.FontSize = 15
$maji9.HorizontalAlignment = 'Center'
$maji9.VerticalAlignment = 'Top'
$maji9.VerticalContentAlignment = 'Center'
$maji9.Margin = [System.Windows.Thickness]::new(46, 360, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji9 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji9.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji9, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji9, 3000)     # Durée d'affichage en millisecondes
$maji9.ToolTip = $tooltipmaji9

$i9comboBox = New-Object System.Windows.Controls.ComboBox
$i9comboBox.Width = 170
$i9comboBox.FontSize = 15
$i9comboBox.IsEditable = $true
$i9comboBox.Focusable = $true
$i9comboBox.Margin = [System.Windows.Thickness]::new($maji9.Margin.Left + $maji9.Width + 14, $maji9.Margin.Top, 0, 0)

$maji9.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i9comboBox.Text) -or [string]::IsNullOrWhiteSpace($i9prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i9comboBox.Text
        $price = $i9prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i9unit.Content = "$global:monnaie/" + $global:unite
        $i9qunit.Content = $global:unite
        $i9comboBox.SelectedItem = $ingredient
    }
    })

$maji10 = New-Object System.Windows.Controls.Button
$maji10.Content = "➕"
$maji10.Width = 26
$maji10.Height = 26
$maji10.FontSize = 15
$maji10.HorizontalAlignment = 'Center'
$maji10.VerticalAlignment = 'Top'
$maji10.VerticalContentAlignment = 'Center'
$maji10.Margin = [System.Windows.Thickness]::new(46, 400, 0, 0) # Position: 20px du bord gauche, 20px du bord supérieur

$tooltipmaji10 = New-Object System.Windows.Controls.ToolTip
$tooltipmaji10.Content = "Mettre à jour ou
créer l'ingrédient"
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($maji10, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($maji10, 3000)     # Durée d'affichage en millisecondes
$maji10.ToolTip = $tooltipmaji10

$i10comboBox = New-Object System.Windows.Controls.ComboBox
$i10comboBox.Width = 170
$i10comboBox.FontSize = 15
$i10comboBox.IsEditable = $true
$i10comboBox.Focusable = $true
$i10comboBox.Margin = [System.Windows.Thickness]::new($maji10.Margin.Left + $maji10.Width + 14, $maji10.Margin.Top, 0, 0)

$maji10.Add_Click({
 if ([string]::IsNullOrWhiteSpace($i10comboBox.Text) -or [string]::IsNullOrWhiteSpace($i10prix.Text)) {
        # Si l'un des contrôles est vide, ne faites rien ou montrez un message d'erreur
        [System.Windows.MessageBox]::Show("$global:erreurmaj", "$global:erreurtitre", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    } else{
        $tag = $_.Source.Tag
        $ingredient = $i10comboBox.Text
        $price = $i10prix.Text
        Update-OrAddIngredient -ingredient $ingredient -price $price
        $i10unit.Content = "$global:monnaie/" + $global:unite
        $i10qunit.Content = $global:unite
        $i10comboBox.SelectedItem = $ingredient
    }
    })

foreach ($ingredient in $data.Keys| Sort-Object) {
    $i1comboBox.Items.Add($ingredient)
    $i2comboBox.Items.Add($ingredient)
    $i3comboBox.Items.Add($ingredient)
    $i4comboBox.Items.Add($ingredient)
    $i5comboBox.Items.Add($ingredient)
    $i6comboBox.Items.Add($ingredient)
    $i7comboBox.Items.Add($ingredient)
    $i8comboBox.Items.Add($ingredient)
    $i9comboBox.Items.Add($ingredient)
    $i10comboBox.Items.Add($ingredient)

}

#endregion

#region affichage du prix et des unités
$i1prix = New-Object System.Windows.Controls.TextBox
$i1prix.Width = 50
$i1prix.FontSize = 15
$i1prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i1prix.Margin = [System.Windows.Thickness]::new($i1comboBox.Margin.Left + $i1comboBox.Width + 15, $i1comboBox.Margin.Top + 2, 0, 0)

$i1unit = New-Object System.Windows.Controls.Label
$i1unit.Width = 50
$i1unit.FontSize = 15
$i1unit.Margin = [System.Windows.Thickness]::new($i1prix.Margin.Left + $i1prix.Width, $i1prix.Margin.Top - 4 , 0, 0)
$i1unit.Content = "$global:monnaie/_"

$i2prix = New-Object System.Windows.Controls.TextBox
$i2prix.Width = 50
$i2prix.FontSize = 15
$i2prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i2prix.Margin = [System.Windows.Thickness]::new($i2comboBox.Margin.Left + $i2comboBox.Width + 15, $i2comboBox.Margin.Top + 2, 0, 0)

$i2unit = New-Object System.Windows.Controls.Label
$i2unit.Width = 50
$i2unit.FontSize = 15
$i2unit.Margin = [System.Windows.Thickness]::new($i2prix.Margin.Left + $i2prix.Width, $i2prix.Margin.Top - 4 , 0, 0)
$i2unit.Content = "$global:monnaie/_"

$i3prix = New-Object System.Windows.Controls.TextBox
$i3prix.Width = 50
$i3prix.FontSize = 15
$i3prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i3prix.Margin = [System.Windows.Thickness]::new($i3comboBox.Margin.Left + $i3comboBox.Width + 15, $i3comboBox.Margin.Top + 2, 0, 0)

$i3unit = New-Object System.Windows.Controls.Label
$i3unit.Width = 50
$i3unit.FontSize = 15
$i3unit.Margin = [System.Windows.Thickness]::new($i3prix.Margin.Left + $i3prix.Width, $i3prix.Margin.Top - 4 , 0, 0)
$i3unit.Content = "$global:monnaie/_"

$i4prix = New-Object System.Windows.Controls.TextBox
$i4prix.Width = 50
$i4prix.FontSize = 15
$i4prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i4prix.Margin = [System.Windows.Thickness]::new($i4comboBox.Margin.Left + $i4comboBox.Width + 15, $i4comboBox.Margin.Top + 2, 0, 0)

$i4unit = New-Object System.Windows.Controls.Label
$i4unit.Width = 50
$i4unit.FontSize = 15
$i4unit.Margin = [System.Windows.Thickness]::new($i4prix.Margin.Left + $i4prix.Width, $i4prix.Margin.Top - 4 , 0, 0)
$i4unit.Content = "$global:monnaie/_"

$i5prix = New-Object System.Windows.Controls.TextBox
$i5prix.Width = 50
$i5prix.FontSize = 15
$i5prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i5prix.Margin = [System.Windows.Thickness]::new($i5comboBox.Margin.Left + $i5comboBox.Width + 15, $i5comboBox.Margin.Top + 2, 0, 0)

$i5unit = New-Object System.Windows.Controls.Label
$i5unit.Width = 50
$i5unit.FontSize = 15
$i5unit.Margin = [System.Windows.Thickness]::new($i5prix.Margin.Left + $i5prix.Width, $i5prix.Margin.Top - 4 , 0, 0)
$i5unit.Content = "$global:monnaie/_"

$i6prix = New-Object System.Windows.Controls.TextBox
$i6prix.Width = 50
$i6prix.FontSize = 15
$i6prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i6prix.Margin = [System.Windows.Thickness]::new($i6comboBox.Margin.Left + $i6comboBox.Width + 15, $i6comboBox.Margin.Top + 2, 0, 0)

$i6unit = New-Object System.Windows.Controls.Label
$i6unit.Width = 50
$i6unit.FontSize = 15
$i6unit.Margin = [System.Windows.Thickness]::new($i6prix.Margin.Left + $i6prix.Width, $i6prix.Margin.Top - 4 , 0, 0)
$i6unit.Content = "$global:monnaie/_"

$i7prix = New-Object System.Windows.Controls.TextBox
$i7prix.Width = 50
$i7prix.FontSize = 15
$i7prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i7prix.Margin = [System.Windows.Thickness]::new($i7comboBox.Margin.Left + $i7comboBox.Width + 15, $i7comboBox.Margin.Top + 2, 0, 0)

$i7unit = New-Object System.Windows.Controls.Label
$i7unit.Width = 50
$i7unit.FontSize = 15
$i7unit.Margin = [System.Windows.Thickness]::new($i7prix.Margin.Left + $i7prix.Width, $i7prix.Margin.Top - 4 , 0, 0)
$i7unit.Content = "$global:monnaie/_"

$i8prix = New-Object System.Windows.Controls.TextBox
$i8prix.Width = 50
$i8prix.FontSize = 15
$i8prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i8prix.Margin = [System.Windows.Thickness]::new($i8comboBox.Margin.Left + $i8comboBox.Width + 15, $i8comboBox.Margin.Top + 2, 0, 0)

$i8unit = New-Object System.Windows.Controls.Label
$i8unit.Width = 50
$i8unit.FontSize = 15
$i8unit.Margin = [System.Windows.Thickness]::new($i8prix.Margin.Left + $i8prix.Width, $i8prix.Margin.Top - 4 , 0, 0)
$i8unit.Content = "$global:monnaie/_"

$i9prix = New-Object System.Windows.Controls.TextBox
$i9prix.Width = 50
$i9prix.FontSize = 15
$i9prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i9prix.Margin = [System.Windows.Thickness]::new($i9comboBox.Margin.Left + $i9comboBox.Width + 15, $i9comboBox.Margin.Top + 2, 0, 0)

$i9unit = New-Object System.Windows.Controls.Label
$i9unit.Width = 50
$i9unit.FontSize = 15
$i9unit.Margin = [System.Windows.Thickness]::new($i9prix.Margin.Left + $i9prix.Width, $i9prix.Margin.Top - 4 , 0, 0)
$i9unit.Content = "$global:monnaie/_"

$i10prix = New-Object System.Windows.Controls.TextBox
$i10prix.Width = 50
$i10prix.FontSize = 15
$i10prix.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i10prix.Margin = [System.Windows.Thickness]::new($i10comboBox.Margin.Left + $i10comboBox.Width + 15, $i10comboBox.Margin.Top + 2, 0, 0)

$i10unit = New-Object System.Windows.Controls.Label
$i10unit.Width = 50
$i10unit.FontSize = 15
$i10unit.Margin = [System.Windows.Thickness]::new($i10prix.Margin.Left + $i10prix.Width, $i10prix.Margin.Top - 4 , 0, 0)
$i10unit.Content = "$global:monnaie/_"

#endregion

#region affichage des quantités et des unités
$i1q = New-Object System.Windows.Controls.TextBox
$i1q.Width = 50
$i1q.FontSize = 15
$i1q.MaxLength = 5
$i1q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i1q.Margin = [System.Windows.Thickness]::new($i1unit.Margin.Left + $i1unit.Width +5, $i1unit.Margin.Top +4 , 0, 0)

$i1qunit = New-Object System.Windows.Controls.Label
$i1qunit.Width = 50
$i1qunit.FontSize = 15
$i1qunit.Margin = [System.Windows.Thickness]::new($i1q.Margin.Left + $i1q.Width, $i1q.Margin.Top - 4 , 0, 0)
$i1qunit.Content = "_"

$i2q = New-Object System.Windows.Controls.TextBox
$i2q.Width = 50
$i2q.FontSize = 15
$i2q.MaxLength = 5
$i2q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i2q.Margin = [System.Windows.Thickness]::new($i2unit.Margin.Left + $i2unit.Width +5, $i2unit.Margin.Top +4 , 0, 0)

$i2qunit = New-Object System.Windows.Controls.Label
$i2qunit.Width = 50
$i2qunit.FontSize = 15
$i2qunit.Margin = [System.Windows.Thickness]::new($i2q.Margin.Left + $i2q.Width, $i2q.Margin.Top - 4 , 0, 0)
$i2qunit.Content = "_"


$i3q = New-Object System.Windows.Controls.TextBox
$i3q.Width = 50
$i3q.FontSize = 15
$i3q.MaxLength = 5
$i3q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i3q.Margin = [System.Windows.Thickness]::new($i3unit.Margin.Left + $i3unit.Width +5, $i3unit.Margin.Top +4 , 0, 0)

$i3qunit = New-Object System.Windows.Controls.Label
$i3qunit.Width = 50
$i3qunit.FontSize = 15
$i3qunit.Margin = [System.Windows.Thickness]::new($i3q.Margin.Left + $i3q.Width, $i3q.Margin.Top - 4 , 0, 0)
$i3qunit.Content = "_"

$i4q = New-Object System.Windows.Controls.TextBox
$i4q.Width = 50
$i4q.FontSize = 15
$i4q.MaxLength = 5
$i4q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i4q.Margin = [System.Windows.Thickness]::new($i4unit.Margin.Left + $i4unit.Width +5, $i4unit.Margin.Top +4 , 0, 0)

$i4qunit = New-Object System.Windows.Controls.Label
$i4qunit.Width = 50
$i4qunit.FontSize = 15
$i4qunit.Margin = [System.Windows.Thickness]::new($i4q.Margin.Left + $i4q.Width, $i4q.Margin.Top - 4 , 0, 0)
$i4qunit.Content = "_"

$i5q = New-Object System.Windows.Controls.TextBox
$i5q.Width = 50
$i5q.FontSize = 15
$i5q.MaxLength = 5
$i5q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i5q.Margin = [System.Windows.Thickness]::new($i5unit.Margin.Left + $i5unit.Width +5, $i5unit.Margin.Top +4 , 0, 0)

$i5qunit = New-Object System.Windows.Controls.Label
$i5qunit.Width = 50
$i5qunit.FontSize = 15
$i5qunit.Margin = [System.Windows.Thickness]::new($i5q.Margin.Left + $i5q.Width, $i5q.Margin.Top - 4 , 0, 0)
$i5qunit.Content = "_"

$i6q = New-Object System.Windows.Controls.TextBox
$i6q.Width = 50
$i6q.FontSize = 15
$i6q.MaxLength = 5
$i6q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i6q.Margin = [System.Windows.Thickness]::new($i6unit.Margin.Left + $i6unit.Width +5, $i6unit.Margin.Top +4 , 0, 0)

$i6qunit = New-Object System.Windows.Controls.Label
$i6qunit.Width = 50
$i6qunit.FontSize = 15
$i6qunit.Margin = [System.Windows.Thickness]::new($i6q.Margin.Left + $i6q.Width, $i6q.Margin.Top - 4 , 0, 0)
$i6qunit.Content = "_"

$i7q = New-Object System.Windows.Controls.TextBox
$i7q.Width = 50
$i7q.FontSize = 15
$i7q.MaxLength = 5
$i7q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i7q.Margin = [System.Windows.Thickness]::new($i7unit.Margin.Left + $i7unit.Width +5, $i7unit.Margin.Top +4 , 0, 0)

$i7qunit = New-Object System.Windows.Controls.Label
$i7qunit.Width = 50
$i7qunit.FontSize = 15
$i7qunit.Margin = [System.Windows.Thickness]::new($i7q.Margin.Left + $i7q.Width, $i7q.Margin.Top - 4 , 0, 0)
$i7qunit.Content = "_"

$i8q = New-Object System.Windows.Controls.TextBox
$i8q.Width = 50
$i8q.FontSize = 15
$i8q.MaxLength = 5
$i8q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i8q.Margin = [System.Windows.Thickness]::new($i8unit.Margin.Left + $i8unit.Width +5, $i8unit.Margin.Top +4 , 0, 0)

$i8qunit = New-Object System.Windows.Controls.Label
$i8qunit.Width = 50
$i8qunit.FontSize = 15
$i8qunit.Margin = [System.Windows.Thickness]::new($i8q.Margin.Left + $i8q.Width, $i8q.Margin.Top - 4 , 0, 0)
$i8qunit.Content = "_"

$i9q = New-Object System.Windows.Controls.TextBox
$i9q.Width = 50
$i9q.FontSize = 15
$i9q.MaxLength = 5
$i9q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i9q.Margin = [System.Windows.Thickness]::new($i9unit.Margin.Left + $i9unit.Width +5, $i9unit.Margin.Top +4 , 0, 0)

$i9qunit = New-Object System.Windows.Controls.Label
$i9qunit.Width = 50
$i9qunit.FontSize = 15
$i9qunit.Margin = [System.Windows.Thickness]::new($i9q.Margin.Left + $i9q.Width, $i9q.Margin.Top - 4 , 0, 0)
$i9qunit.Content = "_"

$i10q = New-Object System.Windows.Controls.TextBox
$i10q.Width = 50
$i10q.FontSize = 15
$i10q.MaxLength = 5
$i10q.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
$i10q.Margin = [System.Windows.Thickness]::new($i10unit.Margin.Left + $i10unit.Width +5, $i10unit.Margin.Top +4 , 0, 0)

$i10qunit = New-Object System.Windows.Controls.Label
$i10qunit.Width = 50
$i10qunit.FontSize = 15
$i10qunit.Margin = [System.Windows.Thickness]::new($i10q.Margin.Left + $i10q.Width, $i10q.Margin.Top - 4 , 0, 0)
$i10qunit.Content = "_"

#endregion

#region valeurs par défaut
$i1comboBox.SelectedItem = "$f1"
$selectedIngredient = $i1comboBox.SelectedItem
    if ($selectedIngredient) {
        $i1prix.Text = $data[$selectedIngredient].Value
        $i1unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i1qunit.Content = $data[$selectedIngredient].Unit
    }

$i2comboBox.SelectedItem = "$f2"
$selectedIngredient = $i2comboBox.SelectedItem
    if ($selectedIngredient) {
        $i2prix.Text = $data[$selectedIngredient].Value
        $i2unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i2qunit.Content = $data[$selectedIngredient].Unit
    }

$i3comboBox.SelectedItem = "$f3"
$selectedIngredient = $i3comboBox.SelectedItem
    if ($selectedIngredient) {
        $i3prix.Text = $data[$selectedIngredient].Value
        $i3unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i3qunit.Content = $data[$selectedIngredient].Unit
    }

    $i4comboBox.SelectedItem = "$f4"
$selectedIngredient = $i4comboBox.SelectedItem
    if ($selectedIngredient) {
        $i4prix.Text = $data[$selectedIngredient].Value
        $i4unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i4qunit.Content = $data[$selectedIngredient].Unit
    }

$i5comboBox.SelectedItem = "$f5"
$selectedIngredient = $i5comboBox.SelectedItem
    if ($selectedIngredient) {
        $i5prix.Text = $data[$selectedIngredient].Value
        $i5unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i5qunit.Content = $data[$selectedIngredient].Unit
    }

$i6comboBox.SelectedItem = "$f6"
$selectedIngredient = $i6comboBox.SelectedItem
    if ($selectedIngredient) {
        $i6prix.Text = $data[$selectedIngredient].Value
        $i6unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i6qunit.Content = $data[$selectedIngredient].Unit
    }

$i7comboBox.SelectedItem = "$f7"
$selectedIngredient = $i7comboBox.SelectedItem
    if ($selectedIngredient) {
        $i7prix.Text = $data[$selectedIngredient].Value
        $i7unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i7qunit.Content = $data[$selectedIngredient].Unit
    }

$i8comboBox.SelectedItem = "$f8"
$selectedIngredient = $i8comboBox.SelectedItem
    if ($selectedIngredient) {
        $i8prix.Text = $data[$selectedIngredient].Value
        $i8unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i8qunit.Content = $data[$selectedIngredient].Unit
    }

    $i9comboBox.SelectedItem = "f9"
$selectedIngredient = $i9comboBox.SelectedItem
    if ($selectedIngredient) {
        $i9prix.Text = $data[$selectedIngredient].Value
        $i9unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i9qunit.Content = $data[$selectedIngredient].Unit
    }

$i10comboBox.SelectedItem = "f10"
$selectedIngredient = $i10comboBox.SelectedItem
    if ($selectedIngredient) {
        $i10prix.Text = $data[$selectedIngredient].Value
        $i10unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i10qunit.Content = $data[$selectedIngredient].Unit
    }

#endregion

#region code d'actualisation
$i1comboBox.Add_SelectionChanged({
    $selectedIngredient = $i1comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i1prix.Text = $data[$selectedIngredient].Value
        $i1unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i1qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i2comboBox.Add_SelectionChanged({
    $selectedIngredient = $i2comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i2prix.Text = $data[$selectedIngredient].Value
        $i2unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i2qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i3comboBox.Add_SelectionChanged({
    $selectedIngredient = $i3comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i3prix.Text = $data[$selectedIngredient].Value
        $i3unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i3qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i4comboBox.Add_SelectionChanged({
    $selectedIngredient = $i4comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i4prix.Text = $data[$selectedIngredient].Value
        $i4unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i4qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i5comboBox.Add_SelectionChanged({
    $selectedIngredient = $i5comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i5prix.Text = $data[$selectedIngredient].Value
        $i5unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i5qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i6comboBox.Add_SelectionChanged({
    $selectedIngredient = $i6comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i6prix.Text = $data[$selectedIngredient].Value
        $i6unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i6qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i7comboBox.Add_SelectionChanged({
    $selectedIngredient = $i7comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i7prix.Text = $data[$selectedIngredient].Value
        $i7unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i7qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i8comboBox.Add_SelectionChanged({
    $selectedIngredient = $i8comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i8prix.Text = $data[$selectedIngredient].Value
        $i8unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i8qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i9comboBox.Add_SelectionChanged({
    $selectedIngredient = $i9comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i9prix.Text = $data[$selectedIngredient].Value
        $i9unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i9qunit.Content = $data[$selectedIngredient].Unit
    }
})

$i10comboBox.Add_SelectionChanged({
    $selectedIngredient = $i10comboBox.SelectedItem
    $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
    if ($selectedIngredient) {
        $i10prix.Text = $data[$selectedIngredient].Value
        $i10unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i10qunit.Content = $data[$selectedIngredient].Unit
    }
})
#endregion

#region colonne de droite
$i1q.Margin = [System.Windows.Thickness]::new($i1unit.Margin.Left + $i1unit.Width +5, $i1unit.Margin.Top +4 , 0, 0)


$parttexte = New-Object System.Windows.Controls.Label
$parttexte.Width = 275
$parttexte.FontSize = 15
$parttexte.HorizontalContentAlignment = 'Left'
$parttexte.FontWeight = 'Bold'
$parttexte.Content = "Nombre de parts :"
$parttexte.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width, 56 , 0, 0)

$nbpart = New-Object System.Windows.Controls.TextBox
$nbpart.Width = 40
$nbpart.FontSize = 15
$nbpart.MaxLength = 4
$nbpart.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
[System.Windows.Controls.Canvas]::SetRight($nbpart, 35) # Position X
[System.Windows.Controls.Canvas]::SetTop($nbpart, 60)  # Position Y

$lottexte = New-Object System.Windows.Controls.Label
$lottexte.Width = 200
$lottexte.Height = 60
$lottexte.FontSize = 15
$lottexte.HorizontalContentAlignment = 'Left'
$lottexte.FontWeight = 'Bold'
$lottexte.Content = "Nombre de parts par lot :"
$lottexte.VerticalContentAlignment = 'Center'
$lottexte.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Left
$lottexte.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width, $parttexte.Margin.Top +25 , 0, 0)

$nblot = New-Object System.Windows.Controls.TextBox
$nblot.Width = 40
$nblot.FontSize = 15
$nblot.MaxLength = 4
$nblot.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
[System.Windows.Controls.Canvas]::SetRight($nblot, 35) # Position X
[System.Windows.Controls.Canvas]::SetTop($nblot, 100)  # Position Y

$prixparttexte = New-Object System.Windows.Controls.Label
$prixparttexte.Width = 230
$prixparttexte.FontSize = 15
$prixparttexte.HorizontalContentAlignment = 'Left'
$prixparttexte.FontWeight = 'Bold'
$prixparttexte.Content = "Prix de vente du lot :"
$prixparttexte.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width, $lottexte.Margin.Top +55 , 0, 0)

$prixpart = New-Object System.Windows.Controls.TextBox
$prixpart.Width = 40
$prixpart.FontSize = 15
$prixpart.MaxLength = 4
$prixpart.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
[System.Windows.Controls.Canvas]::SetRight($prixpart, 35) # Position X
[System.Windows.Controls.Canvas]::SetTop($prixpart, 140)  # Position Y

$europart = New-Object System.Windows.Controls.Label
$europart.Width = 20
$europart.FontSize = 15
$europart.HorizontalContentAlignment = 'Left'
$europart.FontWeight = 'Bold'
$europart.Content = "$global:monnaie"
[System.Windows.Controls.Canvas]::SetRight($europart, 13) # Position X
[System.Windows.Controls.Canvas]::SetTop($europart, 136)  # Position Y


$calcul = New-Object System.Windows.Controls.Button
$calcul.Width = 100
$calcul.FontSize = 15
$calcul.Content = "Calculer"
$calcul.FontWeight = 'Bold'
$calcul.Height = 28
$calcul.HorizontalAlignment = 'Center'
$calcul.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width + 80, $prixparttexte.Margin.Top + 60 , 0, 0)

$couttexte = New-Object System.Windows.Controls.Label
$couttexte.Width = 220
$couttexte.FontSize = 15
$couttexte.HorizontalContentAlignment = 'Left'
$couttexte.FontWeight = 'Bold'
$couttexte.Content = "Coût de la préparation :"
$couttexte.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width, $calcul.Margin.Top + 50 , 0, 0)

$global:cout = New-Object System.Windows.Controls.Label
$global:cout.Width = 80
$global:cout.FontSize = 15
$global:cout.HorizontalContentAlignment = 'Left'
$global:cout.FontWeight = 'Bold'
$global:cout.Content = ""
$global:cout.Foreground = [Windows.Media.Brushes]::Red
[System.Windows.Controls.Canvas]::SetLeft($global:cout, 665) # Position X
[System.Windows.Controls.Canvas]::SetTop($global:cout, 246)  # Position Y

$coutparttexte = New-Object System.Windows.Controls.Label
$coutparttexte.Width = 150
$coutparttexte.FontSize = 15
$coutparttexte.HorizontalContentAlignment = 'Left'
$coutparttexte.FontWeight = 'Bold'
$coutparttexte.Content = "Coût de la part :"
$coutparttexte.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width, $couttexte.Margin.Top + 40 , 0, 0)

$coutpartprix = New-Object System.Windows.Controls.Label
$coutpartprix.Width = 80
$coutpartprix.FontSize = 15
$coutpartprix.HorizontalContentAlignment = 'Left'
$coutpartprix.FontWeight = 'Bold'
$coutpartprix.Content = ""
$coutpartprix.Foreground = [Windows.Media.Brushes]::Blue
[System.Windows.Controls.Canvas]::SetLeft($coutpartprix, 665) # Position X
[System.Windows.Controls.Canvas]::SetTop($coutpartprix, 286)  # Position Y

$coutlottexte = New-Object System.Windows.Controls.Label
$coutlottexte.Width = 150
$coutlottexte.FontSize = 15
$coutlottexte.HorizontalContentAlignment = 'Left'
$coutlottexte.FontWeight = 'Bold'
$coutlottexte.Content = "Coût du lot :"
$coutlottexte.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width, $coutparttexte.Margin.Top + 40 , 0, 0)

$coutlotprix = New-Object System.Windows.Controls.Label
$coutlotprix.Width = 80
$coutlotprix.FontSize = 15
$coutlotprix.HorizontalContentAlignment = 'Left'
$coutlotprix.FontWeight = 'Bold'
$coutlotprix.Content = ""
$coutlotprix.Foreground = [Windows.Media.Brushes]::Blue
[System.Windows.Controls.Canvas]::SetLeft($coutlotprix, 665) # Position X
[System.Windows.Controls.Canvas]::SetTop($coutlotprix, 326)  # Position Y

$beneftexte = New-Object System.Windows.Controls.Label
$beneftexte.Width = 180
$beneftexte.FontSize = 15
$beneftexte.HorizontalContentAlignment = 'Left'
$beneftexte.FontWeight = 'Bold'
$beneftexte.Content = "Bénéfices possibles :"
$beneftexte.Margin = [System.Windows.Thickness]::new($i1qunit.Margin.Left + $i1qunit.Width, $coutlottexte.Margin.Top + 40 , 0, 0)

$benefprix = New-Object System.Windows.Controls.Label
$benefprix.Width = 80
$benefprix.FontSize = 15
$benefprix.HorizontalContentAlignment = 'Left'
$benefprix.FontWeight = 'Bold'
$benefprix.Content = ""
$benefprix.Foreground = [Windows.Media.Brushes]::Green
[System.Windows.Controls.Canvas]::SetLeft($benefprix, 665) # Position X
[System.Windows.Controls.Canvas]::SetTop($benefprix, 366)  # Position Y

$config = New-Object System.Windows.Controls.Button
$config.Content = "🛠"
$config.Width = 30
$config.Height = 30
$config.FontSize = 12
$config.HorizontalAlignment = 'Center'
$config.VerticalAlignment = 'Top'
[System.Windows.Controls.Canvas]::SetRight($config, 35) # Position X
[System.Windows.Controls.Canvas]::SetTop($config, 420) # Position Y
$tooltipconfig = New-Object System.Windows.Controls.ToolTip
$tooltipconfig.Content = 'Fichier de configuration'
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($config, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($config, 3000)     # Durée d'affichage en millisecondes
$config.ToolTip = $tooltipconfig

$updateButton = New-Object System.Windows.Controls.Button
$updateButton.Content = "Recharger"
$updateButton.Width = 100
$updateButton.Height = 30
$updateButton.FontSize = 15
$updateButton.HorizontalAlignment = 'Center'
$updateButton.VerticalAlignment = 'Top'
[System.Windows.Controls.Canvas]::SetLeft($updateButton, 591) # Position X
[System.Windows.Controls.Canvas]::SetTop($updateButton, 420) # Position Y
$tooltipupdate = New-Object System.Windows.Controls.ToolTip
$tooltipupdate.Content = 'Recharger le fichier de configuration'
[System.Windows.Controls.ToolTipService]::SetInitialShowDelay($updateButton, 500)  # Délai avant l'affichage en millisecondes
[System.Windows.Controls.ToolTipService]::SetShowDuration($updateButton, 3000)     # Durée d'affichage en millisecondes
$updateButton.ToolTip = $tooltipupdate

$razButton = New-Object System.Windows.Controls.Button
$razButton.Content = "Remise à zéro"
$razButton.Width = 100
$razButton.Height = 30
$razButton.FontSize = 15
$razButton.HorizontalAlignment = 'Center'
$razButton.VerticalAlignment = 'Top'
[System.Windows.Controls.Canvas]::SetLeft($razButton, 476) # Position X
[System.Windows.Controls.Canvas]::SetTop($razButton, 420) # Position Y

$lang = New-Object System.Windows.Controls.ComboBox
$lang.Width = 62
$lang.Height = 30
$lang.IsReadOnly = $true
$lang.FontSize = 13
$lang.VerticalContentAlignment = 'Center'
[System.Windows.Controls.Canvas]::SetRight($lang, 35) # Position X
[System.Windows.Controls.Canvas]::SetTop($lang, 10)  # Position Y

if (-not (Test-Path $flagfr)) {
    $itemfr = "Fr"
    $lang.Items.Add($itemfr)
      }else{
    $itemfr = New-Object Windows.Controls.ComboBoxItem
    $imgfr = New-Object Windows.Controls.Image
    $imgfr.Source = New-Object Uri($flagfr, [UriKind]::Relative )
    $imgfr.Height = 20
    $itemfr.Content = $imgfr

    $toolTipfr = New-Object System.Windows.Controls.ToolTip
    $toolTipfr.Content = "Français"
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($imgfr, 800)  # Délai avant l'affichage en millisecondes
    [System.Windows.Controls.ToolTipService]::SetShowDuration($imgfr, 3000)     # Durée d'affichage en millisecondes
    $imgfr.ToolTip = $toolTipfr

    $lang.Items.Add($itemfr)
    }

if (-not (Test-Path $flaggb)) {
    $itemgb = "Eng"
    $lang.Items.Add($itemgb)
      }else{
    $itemgb = New-Object Windows.Controls.ComboBoxItem
    $imggb = New-Object Windows.Controls.Image
    $imggb.Source = New-Object Uri($flaggb, [UriKind]::Relative )
    $imggb.Height = 20
    $itemgb.Content = $imggb

    $toolTipgb = New-Object System.Windows.Controls.ToolTip
    $toolTipgb.Content = "English (£)"
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($imggb, 800)  # Délai avant l'affichage en millisecondes
    [System.Windows.Controls.ToolTipService]::SetShowDuration($imggb, 3000)     # Durée d'affichage en millisecondes
    $imggb.ToolTip = $toolTipgb
    
    $lang.Items.Add($itemgb)
      }

if (-not (Test-Path $flages)) {
    $itemes = "Es"
    $lang.Items.Add($itemes)
      }else{
    $itemes = New-Object Windows.Controls.ComboBoxItem
    $imges = New-Object Windows.Controls.Image
    $imges.Source = New-Object Uri($flages, [UriKind]::Relative )
    $imges.Height = 20
    $itemes.Content = $imges

    $toolTipes = New-Object System.Windows.Controls.ToolTip
    $toolTipes.Content = "Español"
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($imges, 800)  # Délai avant l'affichage en millisecondes
    [System.Windows.Controls.ToolTipService]::SetShowDuration($imges, 3000)     # Durée d'affichage en millisecondes
    $imges.ToolTip = $toolTipes

    $lang.Items.Add($itemes)
    }

if (-not (Test-Path $flagit)) {
    $itemit = "It"
    $lang.Items.Add($itemit)
      }else{
    $itemit = New-Object Windows.Controls.ComboBoxItem
    $imgit = New-Object Windows.Controls.Image
    $imgit.Source = New-Object Uri($flagit, [UriKind]::Relative )
    $imgit.Height = 20
    $itemit.Content = $imgit

    $toolTipit = New-Object System.Windows.Controls.ToolTip
    $toolTipit.Content = "Italiano"
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($imgit, 800)  # Délai avant l'affichage en millisecondes
    [System.Windows.Controls.ToolTipService]::SetShowDuration($imgit, 3000)     # Durée d'affichage en millisecondes
    $imgit.ToolTip = $toolTipit

    $lang.Items.Add($itemit)
    }

if (-not (Test-Path $flagde)) {
    $itemde = "De"
    $lang.Items.Add($itemde)
      }else{
    $itemde = New-Object Windows.Controls.ComboBoxItem
    $imgde = New-Object Windows.Controls.Image
    $imgde.Source = New-Object Uri($flagde, [UriKind]::Relative )
    $imgde.Height = 20
    $itemde.Content = $imgde

    $toolTipde = New-Object System.Windows.Controls.ToolTip
    $toolTipde.Content = "Deutsch"
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($imgde, 800)  # Délai avant l'affichage en millisecondes
    [System.Windows.Controls.ToolTipService]::SetShowDuration($imgde, 3000)     # Durée d'affichage en millisecondes
    $imgde.ToolTip = $toolTipde

    $lang.Items.Add($itemde)
    }

if (-not (Test-Path $flagus)) {
    $itemus = "US"
    $lang.Items.Add($itemus)
      }else{
    $itemus = New-Object Windows.Controls.ComboBoxItem
    $imgus = New-Object Windows.Controls.Image
    $imgus.Source = New-Object Uri($flagus, [UriKind]::Relative )
    $imgus.Height = 20
    $itemus.Content = $imgus

    $toolTipus = New-Object System.Windows.Controls.ToolTip
    $toolTipus.Content = "English ($)"
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($imgus, 800)  # Délai avant l'affichage en millisecondes
    [System.Windows.Controls.ToolTipService]::SetShowDuration($imgus, 3000)     # Durée d'affichage en millisecondes
    $imgus.ToolTip = $toolTipus

    $lang.Items.Add($itemus)
    }


$lang.selecteditem = $itemfr

 #endregion

 #region titres des colonnes
$ititre = New-Object System.Windows.Controls.Label
$ititre.Width = 150
$ititre.FontSize = 15
$ititre.HorizontalContentAlignment = 'Center'
$ititre.FontWeight = 'Bold'
$ititre.Content = "INGRÉDIENTS"

$ititreLeft = $i1comboBox.Margin.Left + ($i1comboBox.Width - $ititre.Width) / 2
[System.Windows.Controls.Canvas]::SetLeft($ititre, $ititreLeft)
[System.Windows.Controls.Canvas]::SetTop($ititre, 5)  # Position Y

$prixtitre = New-Object System.Windows.Controls.Label
$prixtitre.Width = 70
$prixtitre.FontSize = 15
$prixtitre.HorizontalContentAlignment = 'Center'
$prixtitre.FontWeight = 'Bold'
$prixtitre.Content = "PRIX"
[System.Windows.Controls.Canvas]::SetLeft($prixtitre, 261) # Position X
[System.Windows.Controls.Canvas]::SetTop($prixtitre, 5)  # Position Y

$qtitre = New-Object System.Windows.Controls.Label
$qtitre.Width = 110
$qtitre.FontSize = 15
$qtitre.HorizontalContentAlignment = 'Center'
$qtitre.FontWeight = 'Bold'
$qtitre.Content = "QUANTITÉS"
[System.Windows.Controls.Canvas]::SetLeft($qtitre, 350) # Position X
[System.Windows.Controls.Canvas]::SetTop($qtitre, 5)  # Position Y
#endregion

 function reload-lang-monnaie{
     if (-not $i1comboBox.SelectedItem){}else{
      $selectedIngredient = $i1comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i1unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i2comboBox.SelectedItem){}else{
      $selectedIngredient = $i2comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i2unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i3comboBox.SelectedItem){}else{
      $selectedIngredient = $i3comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i3unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i4comboBox.SelectedItem){}else{
      $selectedIngredient = $i4comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i4unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i5comboBox.SelectedItem){}else{
      $selectedIngredient = $i5comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i5unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i6comboBox.SelectedItem){}else{
      $selectedIngredient = $i6comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i6unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i7comboBox.SelectedItem){}else{
      $selectedIngredient = $i7comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i7unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i8comboBox.SelectedItem){}else{
      $selectedIngredient = $i8comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i8unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i9comboBox.SelectedItem){}else{
      $selectedIngredient = $i9comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i9unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if (-not $i10comboBox.SelectedItem){}else{
      $selectedIngredient = $i10comboBox.SelectedItem
      $selectedKey = $data.Keys | Where-Object { $data[$_].Ingredient -eq $selectedIngredient }
      $i10unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit}

      if ($global:coutgateau -eq $null){}else{
      $global:cout.content = $global:coutgateau.ToString("F2") + " $global:monnaie"}

      if ($global:coutpart -eq $null){}else{
      $coutpartprix.content = $global:coutpart.ToString("F2") + " $global:monnaie"}

      if ($global:coutlot -eq $null){}else{
      $coutlotprix.content = $global:coutlot.ToString("F2") + " $global:monnaie"}

      if ($global:benef -eq $null){}else{
      $benefprix.content = $global:benef.ToString("F2") + " $global:monnaie"}

 }

function calcul{
$i1c = [double]$i1prix.Text
    $i1qc = [double]$i1q.Text
    $i2c = [double]$i2prix.Text
    $i2qc = [double]$i2q.Text
    $i3c = [double]$i3prix.Text
    $i3qc = [double]$i3q.Text
    $i4c = [double]$i4prix.Text
    $i4qc = [double]$i4q.Text
    $i5c = [double]$i5prix.Text
    $i5qc = [double]$i5q.Text
    $i6c = [double]$i6prix.Text
    $i6qc = [double]$i6q.Text
    $i7c = [double]$i7prix.Text
    $i7qc = [double]$i7q.Text
    $i8c = [double]$i8prix.Text
    $i8qc = [double]$i8q.Text
    $i9c = [double]$i9prix.Text
    $i9qc = [double]$i9q.Text
    $i10c = [double]$i10prix.Text
    $i10qc = [double]$i10q.Text
    $part = [double]$nbpart.Text
    $pvpart = [double]$prixpart.Text
    $nblot = [double]$nblot.Text


    $global:coutgateau = $i1c*$i1qc + $i2c*$i2qc + $i3c*$i3qc + $i4c*$i4qc + $i5c*$i5qc + $i6c*$i6qc + $i7c*$i7qc + $i8c*$i8qc + $i9c*$i9qc + $i10c*$i10qc
    $global:cout.content = $global:coutgateau.ToString("F2") + " $global:monnaie"

    if($part -eq 0){}
    else{
    $global:coutpart = $coutgateau / $part
    $coutpartprix.content = $global:coutpart.ToString("F2") + " $global:monnaie"
    }

    if($nblot -eq 0){}
    else{
    $global:coutlot = $global:coutgateau / ($part/$nblot)
    $coutlotprix.Content = $global:coutlot.ToString("F2") + " $global:monnaie"
    }

    if($pvpart -eq 0){}
    else{
    $global:benef = ($part/$nblot)*$pvpart - $global:coutgateau
    $benefprix.content = $global:benef.ToString("F2") + " $global:monnaie"
    }

 }

 $calcul.Add_Click({
   calcul
})


#region Gestion de la touche Entrée
function Handle-EnterKey {
    param (
        [System.Windows.Controls.TextBox]$textBox
    )

    $textBox.Add_KeyDown({
        param($sender, $e)
        if ($e.Key -eq [System.Windows.Input.Key]::Enter) {
            $calcul.RaiseEvent([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)
        }
    })
}

# Associer la gestion de la touche Entrée à tous les TextBox
Handle-EnterKey -textBox $i1q
Handle-EnterKey -textBox $i2q
Handle-EnterKey -textBox $i3q
Handle-EnterKey -textBox $i4q
Handle-EnterKey -textBox $i5q
Handle-EnterKey -textBox $i6q
Handle-EnterKey -textBox $i7q
Handle-EnterKey -textBox $i8q
Handle-EnterKey -textBox $i9q
Handle-EnterKey -textBox $i10q
Handle-EnterKey -textBox $nbpart
Handle-EnterKey -textBox $prixpart
#endregion

# Fonction pour recharger les données
function Reload-Data {

($global:f1, $global:f2, $global:f3, $global:f4, $global:f5, $global:f6, $global:f7, $global:f8, $global:f9, $global:f10) =""

$textboxes = @($i1prix, $i2prix, $i3prix, $i4prix, $i5prix, $i6prix, $i7prix, $i8prix, $i9prix, $i10prix, $i1q, $i2q, $i3q, $i4q, $i5q, $i6q, $i7q, $i8q, $i9q, $i10q)
foreach ($textBox in $textboxes) {
    if ($textBox -is [System.Windows.Controls.TextBox]) {
        $textBox.Text = ""
    }
}

$labels = @($i1unit, $i2unit, $i3unit, $i4unit, $i5unit, $i6unit, $i7unit, $i8unit, $i9unit, $i10unit, $i1qunit, $i2qunit, $i3qunit, $i4qunit, $i5qunit, $i6qunit, $i7qunit, $i8qunit, $i9qunit, $i10qunit)
foreach ($label in $labels) {
    if ($label -is [System.Windows.Controls.Label]) {
        $label.Content = ""
    }
}
    $global:data = @{}
    $global:content = Get-Content $filePath -Encoding UTF8
    $fList = @()

    Load-Favorites
    Load-Data -startChar 'I'    

    # Mettre à jour les ComboBox
    $comboBoxes = @($i1comboBox, $i2comboBox, $i3comboBox, $i4comboBox, $i5comboBox, $i6comboBox, $i7comboBox, $i8comboBox, $i9comboBox, $i10comboBox)
    foreach ($comboBox in $comboBoxes) {
        $comboBox.Items.Clear()
        foreach ($ingredient in $data.Keys | Sort-Object) {
            $comboBox.Items.Add($ingredient)
        }
    }

    # Mettre à jour les valeurs par défaut des ComboBox

$i1comboBox.SelectedItem = "$f1"
$selectedIngredient = $i1comboBox.SelectedItem
    if ($selectedIngredient) {
        $i1prix.Text = $data[$selectedIngredient].Value
        $i1unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i1qunit.Content = $data[$selectedIngredient].Unit
    }

$i2comboBox.SelectedItem = "$f2"
$selectedIngredient = $i2comboBox.SelectedItem
    if ($selectedIngredient) {
        $i2prix.Text = $data[$selectedIngredient].Value
        $i2unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i2qunit.Content = $data[$selectedIngredient].Unit
    }

$i3comboBox.SelectedItem = "$f3"
$selectedIngredient = $i3comboBox.SelectedItem
    if ($selectedIngredient) {
        $i3prix.Text = $data[$selectedIngredient].Value
        $i3unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i3qunit.Content = $data[$selectedIngredient].Unit
    }

    $i4comboBox.SelectedItem = "$f4"
$selectedIngredient = $i4comboBox.SelectedItem
    if ($selectedIngredient) {
        $i4prix.Text = $data[$selectedIngredient].Value
        $i4unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i4qunit.Content = $data[$selectedIngredient].Unit
    }

$i5comboBox.SelectedItem = "$f5"
$selectedIngredient = $i5comboBox.SelectedItem
    if ($selectedIngredient) {
        $i5prix.Text = $data[$selectedIngredient].Value
        $i5unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i5qunit.Content = $data[$selectedIngredient].Unit
    }

$i6comboBox.SelectedItem = "$f6"
$selectedIngredient = $i6comboBox.SelectedItem
    if ($selectedIngredient) {
        $i6prix.Text = $data[$selectedIngredient].Value
        $i6unit.Content = "$global:monnaie/" + $global:data[$selectedIngredient].Unit
        $i6qunit.Content = $global:data[$selectedIngredient].Unit
    }

$i7comboBox.SelectedItem = "$f7"
$selectedIngredient = $i7comboBox.SelectedItem
    if ($selectedIngredient) {
        $i7prix.Text = $data[$selectedIngredient].Value
        $i7unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i7qunit.Content = $data[$selectedIngredient].Unit
    }

$i8comboBox.SelectedItem = "$f8"
$selectedIngredient = $i8comboBox.SelectedItem
    if ($selectedIngredient) {
        $i8prix.Text = $data[$selectedIngredient].Value
        $i8unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i8qunit.Content = $data[$selectedIngredient].Unit
    }

    $i9comboBox.SelectedItem = "f9"
$selectedIngredient = $i9comboBox.SelectedItem
    if ($selectedIngredient) {
        $i9prix.Text = $data[$selectedIngredient].Value
        $i9unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i9qunit.Content = $data[$selectedIngredient].Unit
    }

$i10comboBox.SelectedItem = "f10"
$selectedIngredient = $i10comboBox.SelectedItem
    if ($selectedIngredient) {
        $i10prix.Text = $data[$selectedIngredient].Value
        $i10unit.Content = "$global:monnaie/" + $data[$selectedIngredient].Unit
        $i10qunit.Content = $data[$selectedIngredient].Unit
    }


}

# Ajouter l'événement pour le bouton
$updateButton.Add_Click({
    Reload-Data
})

$razButton.Add_Click({
    $i1q.text = ""
    $i2q.text = ""
    $i3q.text = ""
    $i4q.text = ""
    $i5q.text = ""
    $i6q.text = ""
    $i7q.text = ""
    $i8q.text = ""
    $i9q.text = ""
    $i10q.text = ""
    $nbpart.text = ""
    $nblot.text = ""
    $prixpart.text = ""
    $cout.content = ""
    $global:coutgateau = $null
    $global:coutpart = $null
    $global:coutlot = $null
    $global:benef = $null
    $coutpartprix.content = ""
    $coutlotprix.Content = ""
    $benefprix.content = ""


})

$config.Add_Click({
Start-Process notepad.exe $filePath
})

#region Ajouter la TextBox au Canvas
$canvas.Children.Add($i1comboBox)
$canvas.Children.Add($maji1)
$canvas.Children.Add($i2comboBox)
$canvas.Children.Add($maji2)
$canvas.Children.Add($i3comboBox)
$canvas.Children.Add($maji3)
$canvas.Children.Add($i4comboBox)
$canvas.Children.Add($maji4)
$canvas.Children.Add($i5comboBox)
$canvas.Children.Add($maji5)
$canvas.Children.Add($i6comboBox)
$canvas.Children.Add($maji6)
$canvas.Children.Add($i7comboBox)
$canvas.Children.Add($maji7)
$canvas.Children.Add($i8comboBox)
$canvas.Children.Add($maji8)
$canvas.Children.Add($i9comboBox)
$canvas.Children.Add($maji9)
$canvas.Children.Add($i10comboBox)
$canvas.Children.Add($maji10)
$canvas.Children.Add($i1unit)
$canvas.Children.Add($i1prix)
$canvas.Children.Add($i2unit)
$canvas.Children.Add($i2prix)
$canvas.Children.Add($i3unit)
$canvas.Children.Add($i3prix)
$canvas.Children.Add($i4unit)
$canvas.Children.Add($i4prix)
$canvas.Children.Add($i5unit)
$canvas.Children.Add($i5prix)
$canvas.Children.Add($i6unit)
$canvas.Children.Add($i6prix)
$canvas.Children.Add($i7unit)
$canvas.Children.Add($i7prix)
$canvas.Children.Add($i8unit)
$canvas.Children.Add($i8prix)
$canvas.Children.Add($i9unit)
$canvas.Children.Add($i9prix)
$canvas.Children.Add($i10unit)
$canvas.Children.Add($i10prix)
$canvas.Children.Add($i1q)
$canvas.Children.Add($i1qunit)
$canvas.Children.Add($i2q)
$canvas.Children.Add($i2qunit)
$canvas.Children.Add($i3q)
$canvas.Children.Add($i3qunit)
$canvas.Children.Add($i4q)
$canvas.Children.Add($i4qunit)
$canvas.Children.Add($i5q)
$canvas.Children.Add($i5qunit)
$canvas.Children.Add($i6q)
$canvas.Children.Add($i6qunit)
$canvas.Children.Add($i7q)
$canvas.Children.Add($i7qunit)
$canvas.Children.Add($i8q)
$canvas.Children.Add($i8qunit)
$canvas.Children.Add($i9q)
$canvas.Children.Add($i9qunit)
$canvas.Children.Add($i10q)
$canvas.Children.Add($i10qunit)
$canvas.Children.Add($ititre)
$canvas.Children.Add($prixtitre)
$canvas.Children.Add($qtitre)
$canvas.Children.Add($parttexte)
$canvas.Children.Add($nbpart)
$canvas.Children.Add($prixparttexte)
$canvas.Children.Add($prixpart)
$canvas.Children.Add($europart)
$canvas.Children.Add($calcul)
$canvas.Children.Add($cout)
$canvas.Children.Add($couttexte)
$canvas.Children.Add($coutparttexte)
$canvas.Children.Add($coutpartprix)
$canvas.Children.Add($coutlottexte)
$canvas.Children.Add($coutlotprix)
$canvas.Children.Add($beneftexte)
$canvas.Children.Add($benefprix)
$canvas.Children.Add($updateButton)
$canvas.Children.Add($razButton)
$canvas.Children.Add($lang)
$canvas.Children.Add($config)
$canvas.Children.Add($lottexte)
$canvas.Children.Add($nblot)
$canvas.Children.Add($fav1)
$canvas.Children.Add($fav2)
$canvas.Children.Add($fav3)
$canvas.Children.Add($fav4)
$canvas.Children.Add($fav5)
$canvas.Children.Add($fav6)
$canvas.Children.Add($fav7)
$canvas.Children.Add($fav8)
$canvas.Children.Add($fav9)
$canvas.Children.Add($fav10)

#endregion

# Définir le contenu de la fenêtre
$mainWindow.Content = $canvas

#region langue
function Update-Language {

    $content = Get-Content -Path "config.txt" -Encoding UTF8

    # Mettre à jour la ligne avec la nouvelle langue
    $updatedContent = $content -replace '^Langue=.*$', "Langue=$newLang"

    # Écrire les modifications dans le fichier
    Set-Content -Path "config.txt" -Value $updatedContent -Encoding UTF8
}

function langfr{
      $ititre.Content = "INGRÉDIENTS"
      $qtitre.Content = "QUANTITÉS"
      $prixtitre.Content = "PRIX"
      $parttexte.Content = "Nombre de parts :"
      $lottexte.Content = "Nombre de parts par lot :"
      $prixparttexte.Content = "Prix de vente de la part :"
      $calcul.Content = "Calculer"
      $couttexte.Content = "Coût de la préparation :"
      $coutparttexte.Content = "Coût de la part :"
      $coutlottexte.Content = "Coût du lot :"
      $beneftexte.Content = "Bénéfices possibles :"
      $razButton.Content = "Remise à zéro"
      $updateButton.Content = "Recharger"
      $global:monnaie = "€"
      reload-lang-monnaie
      $europart.Content = "$global:monnaie"
      $global:erreurmaj = "L'ingrédient et son prix doivent être renseignés."
      $global:erreurtitre = "Champ manquant"
      @($tooltipmaji1, $tooltipmaji2, $tooltipmaji3, $tooltipmaji4, $tooltipmaji5, $tooltipmaji6, $tooltipmaji7, $tooltipmaji8, $tooltipmaji9, $tooltipmaji10) | ForEach-Object { $_.Content = "Mettre à jour ou
créer l'ingrédient" }
      $tooltipupdate.Content = 'Recharger le fichier de configuration'
      $tooltipconfig.Content = 'Fichier de configuration'
      $global:titreunite = "Entrer l'unité pour l'ingrédient"
      $global:actionmaj = "mis à jour"
      $global:actionajout = "ajouté"
      $global:message1 = "L'ingrédient"
      $global:message2 = "a été"
      $global:message3 = "pour"
      $global:message4 = "avec succès"
      $global:title = "Confirmation"
      $global:messagefavorisajout = "a été ajouté au favoris"
      $global:messagefavoris = "Veuillez d'abord ajouter l'ingrédient avant de le mettre en favoris"
      $global:confirmation = "Confirmation"
      $global:avertissement = "Avertissement"
      $tooltipfav.Content = "Ajouter l'ingrédient aux favoris"

}

function langeng {
      $ititre.Content = "INGREDIENTS"
      $qtitre.Content = "QUANTITIES"
      $prixtitre.Content = "PRICE"
      $parttexte.Content = "Number of slices :"
      $lottexte.Content = "Number of slices per lot :"
      $prixparttexte.Content = “Sale price of the lot :"
      $calcul.Content = "Calculate"
      $couttexte.Content = "Cost of preparation :"
      $coutparttexte.Content = "Cost of the slice :"
      $coutlottexte.Content = "Cost of the lot :"
      $beneftexte.Content = "Possible benefits :"
      $razButton.Content = "Reset"
      $updateButton.Content = "Reload"
      $global:monnaie = "£"
      reload-lang-monnaie
      $europart.Content = "$global:monnaie"
      $global:erreurmaj = "The ingredient and its price must be indicated."
      $global:erreurtitre = "Missing field"
      @($tooltipmaji1, $tooltipmaji2, $tooltipmaji3, $tooltipmaji4, $tooltipmaji5, $tooltipmaji6, $tooltipmaji7, $tooltipmaji8, $tooltipmaji9, $tooltipmaji10) | ForEach-Object { $_.Content = "Update or create the ingredient" }
      $tooltipupdate.Content = 'Reload configuration file'
      $tooltipconfig.Content = 'Configuration file'
      $global:titreunite = "Enter the unit for the ingredient"
      $global:actionmaj = "updated"
      $global:actionajout = "added"
      $global:message1 = "The ingredient"
      $global:message2 = "has been"
      $global:message3 = "for"
      $global:message4 = "successfully"
      $global:title = "Confirmation"
      $global:messagefavorisajout = "was added to favorites"
      $global:messagefavoris = "Please add the ingredient first before favorite it"
      $global:confirmation = "Confirmation"
      $global:avertissement = "Warning"
      $tooltipfav.Content = "Add ingredient to favorites"
}

function langde {
      $ititre.Content = "ZUTATEN"
      $qtitre.Content = "MENGEN"
      $prixtitre.Content = "PREIS"
      $parttexte.Content = "Anzahl der Kuchenstücke :"
      $lottexte.Content = "Anzahl der Kuchenstücke
pro charge :"
      $prixparttexte.Content = "Verkaufspreis der Aktie :"
      $calcul.Content = "Berechnen"
      $couttexte.Content = "Kosten für die Vorbereitung :"
      $coutparttexte.Content = "Kosten der Aktie :"
      $coutlottexte.Content = "Kosten der charge :"
      $beneftexte.Content = "Mögliche Vorteile :"
      $razButton.Content = "Zurücksetzen"
      $updateButton.Content = "Neu laden"
      $global:monnaie = "€"
      reload-lang-monnaie
      $europart.Content = "$global:monnaie"
      @($tooltipmaji1, $tooltipmaji2, $tooltipmaji3, $tooltipmaji4, $tooltipmaji5, $tooltipmaji6, $tooltipmaji7, $tooltipmaji8, $tooltipmaji9, $tooltipmaji10) | ForEach-Object { $_.Content = "Aktualisieren oder erstellen
Sie die Zutat" }
      $tooltipupdate.Content = 'Konfigurationsdatei neu laden'
      $tooltipconfig.Content = 'Konfigurationsdatei'
      $global:titreunite = "Geben Sie die Einheit für die Zutat ein"
      $global:actionmaj = "aktualisiert"
      $global:actionajout = "hinzugefügt"
      $global:message1 = "Die Zutatent"
      $global:message2 = "war"
      $global:message3 = "für"
      $global:message4 = "erfolgreich"
      $global:title = "Bestätigung"
      $global:messagefavorisajout = "wurde zu den Favoriten hinzugefügt"
      $global:messagefavoris = "Bitte fügen Sie zuerst die Zutat hinzu, bevor Sie sie zu Ihren Favoriten hinzufügen"
      $global:confirmation = "Bestätigung"
      $global:avertissement = "Warnung"
      $tooltipfav.Content = "Zutat zu Favoriten hinzufügen"
}

function langes {
      $ititre.Content = "INGREDIENTES"
      $qtitre.Content = "CANTIDADES"
      $prixtitre.Content = "PRECIO"
      $parttexte.Content = "Número del trozo :"
      $lottexte.Content = "Número del troz por lote :"
      $prixparttexte.Content = "Precio de venta del trozo :"
      $calcul.Content = "Calcular"
      $couttexte.Content = "Costo de preparación :"
      $coutparttexte.Content = "Costo del trozos :"
      $coutlottexte.Content = "Costo del lote :"
      $beneftexte.Content = "Posibles beneficios :"
      $razButton.Content = "Reiniciar"
      $updateButton.Content = "Recargar"
      $global:monnaie = "€"
      reload-lang-monnaie
      $europart.Content = "$global:monnaie"
      @($tooltipmaji1, $tooltipmaji2, $tooltipmaji3, $tooltipmaji4, $tooltipmaji5, $tooltipmaji6, $tooltipmaji7, $tooltipmaji8, $tooltipmaji9, $tooltipmaji10) | ForEach-Object { $_.Content = "Actualizar o crear el ingrediente" }
      $tooltipupdate.Content = 'Recargar archivo de configuración'
      $tooltipconfig.Content = 'Archivo de configuración'
      $global:titreunite = "Ingrese la unidad para el ingrediente"
      $global:actionmaj = "actualizado"
      $global:actionajout = "agregado"
      $global:message1 = "el ingrediente"
      $global:message2 = "ha sido"
      $global:message3 = "para"
      $global:message4 = "exitosamente"
      $global:title = "Confirmación"
      $global:messagefavorisajout = "fue agregado a favoritos"
      $global:messagefavoris = "Por favor agregue el ingrediente primero antes de marcarlo como favorito."
      $global:confirmation = "Confirmación"
      $global:avertissement = "Advertencia"
      $tooltipfav.Content = "Agregar ingrediente a favoritos"
}

function langus {
      $ititre.Content = "INGREDIENTS"
      $qtitre.Content = "QUANTITIES"
      $prixtitre.Content = "PRICE"
      $parttexte.Content = "Number of slices :"
      $lottexte.Content = "Number of slices per lot :"
      $prixparttexte.Content = “Sale price of the slice :"
      $calcul.Content = "Calculate"
      $couttexte.Content = "Cost of preparation :"
      $coutparttexte.Content = "Cost of the slice :"
      $coutlottexte.Content = "Cost of the lot :"
      $beneftexte.Content = "Possible benefits :"
      $razButton.Content = "Reset"
      $updateButton.Content = "Reload"
      $global:monnaie = "$"
      reload-lang-monnaie
      $europart.Content = "$global:monnaie"
      @($tooltipmaji1, $tooltipmaji2, $tooltipmaji3, $tooltipmaji4, $tooltipmaji5, $tooltipmaji6, $tooltipmaji7, $tooltipmaji8, $tooltipmaji9, $tooltipmaji10) | ForEach-Object { $_.Content = "Update or create the ingredient" }
      $tooltipupdate.Content = 'Reload configuration file'
      $tooltipconfig.Content = 'Configuration file'
      $global:titreunite = "Enter the unit for the ingredient"
      $global:actionmaj = "updated"
      $global:actionajout = "added"
      $global:message1 = "The ingredient"
      $global:message2 = "has been"
      $global:message3 = "for"
      $global:message4 = "successfully"
      $global:title = "Confirmation"
      $global:messagefavorisajout = "was added to favorites"
      $global:messagefavoris = "Please add the ingredient first before favorite it"
      $global:confirmation = "Confirmation"
      $global:avertissement = "Warning"
      $tooltipfav.Content = "Add ingredient to favorites"
}

function langit {
      $ititre.Content = "INGREDIENTI"
      $qtitre.Content = "QUANTITÀ"
      $prixtitre.Content = "PREZZO"
      $parttexte.Content = "Numero di fette :"
      $lottexte.Content = "Numero di fette per lotto :"
      $prixparttexte.Content = “Prezzo di vendita del lotto :"
      $calcul.Content = "Calcolare"
      $couttexte.Content = "Costo della preparazione :"
      $coutparttexte.Content = "Costo della fetta :"
      $coutlottexte.Content = "Costo del lotto :"
      $beneftexte.Content = "Possibili benefici :"
      $razButton.Content = "Reset"
      $updateButton.Content = "Ricaricare"
      $global:monnaie = "€"
      reload-lang-monnaie
      $europart.Content = "$global:monnaie"
      @($tooltipmaji1, $tooltipmaji2, $tooltipmaji3, $tooltipmaji4, $tooltipmaji5, $tooltipmaji6, $tooltipmaji7, $tooltipmaji8, $tooltipmaji9, $tooltipmaji10) | ForEach-Object { $_.Content = "Aggiornare o creare l'ingrediente" }
      $tooltipupdate.Content = 'Ricaricare il file di configurazione'
      $tooltipconfig.Content = 'File di configurazione'
      $global:titreunite = "Inserisci l'unità dell'ingredientet"
      $global:actionmaj = "aggiornato"
      $global:actionajout = "aggiunto"
      $global:message1 = "L'ingrediente"
      $global:message2 = "è stato"
      $global:message3 = "per"
      $global:message4 = "con successo"
      $global:title = "Conferma"
      $global:messagefavorisajout = "è stato aggiunto ai preferiti"
      $global:messagefavoris = "Si prega di aggiungere l'ingrediente prima di aggiungerlo ai preferiti"
      $global:confirmation = "Conferma"
      $global:avertissement = "Avvertimento"
      $tooltipfav.Content = "Aggiungi l'ingrediente ai preferiti"
}

 if ($global:langue -eq "Fr"){       
    langfr
       $lang.selecteditem = $itemfr}
 else{
    if ($global:langue -eq "Eng") {
      langeng
      $lang.selecteditem = $itemgb
    }
     if ($global:langue -eq "Fr") {
       langfr
       $lang.selecteditem = $itemfr
    }

      if ($global:langue -eq "De") {
        langde
        $lang.selecteditem = $itemde

    }

      if ($global:langue -eq "Es") {
      langes
      $lang.selecteditem = $itemes
    }

      if ($global:langue -eq "US") {
      langus
      $lang.selecteditem = $itemus
      }

      if ($global:langue -eq "It") {
      langit
      $lang.selecteditem = $itemit
      }
 }
   

 $lang.Add_SelectionChanged({
    $selectedlang = $lang.SelectedItem

    if ($selectedlang -eq $itemgb) {
    langeng
    $newLang = "Eng"
    Update-Language -newLang $selectedLang
    }
    if ($selectedlang -eq $itemfr) {
    langfr
    $newLang = "Fr"
    Update-Language -newLang $selectedLang
    }

    if ($selectedlang -eq $itemde) {
    langde
    $newLang = "De"
    Update-Language -newLang $selectedLang
    }

    if ($selectedlang -eq $itemes) {
    langes
    $newLang = "Es"
    Update-Language -newLang $selectedLang
    }

    if ($selectedlang -eq $itemus) {
    langus
    $newLang = "US"
    Update-Language -newLang $selectedLang
    }

    if ($selectedlang -eq $itemit) {
    langit
    $newLang = "It"
    Update-Language -newLang $selectedLang
    }
})
#endregion

#region Sélection des cases
# Fonction pour sélectionner tout le texte
$selectAllText = {
    param ($sender, $eventArgs)
    $textBox = $sender -as [Windows.Controls.TextBox]
    if ($textBox) {
        $textBox.SelectAll()
    }
}

# Attachement des événements GotFocus aux TextBox
$i1q.Add_GotFocus($selectAllText)
$i2q.Add_GotFocus($selectAllText)
$i3q.Add_GotFocus($selectAllText)
$i4q.Add_GotFocus($selectAllText)
$i5q.Add_GotFocus($selectAllText)
$i6q.Add_GotFocus($selectAllText)
$i7q.Add_GotFocus($selectAllText)
$i8q.Add_GotFocus($selectAllText)
$i9q.Add_GotFocus($selectAllText)
$i10q.Add_GotFocus($selectAllText)
$nbpart.Add_GotFocus($selectAllText)
$prixpart.Add_GotFocus($selectAllText)
#endregion

#region autorisation saisie
# Fonction pour valider les entrées : autoriser uniquement les chiffres et les points
$validateInput = {
    param ($sender, $eventArgs)
    $textBox = $sender -as [Windows.Controls.TextBox]
    $newChar = $eventArgs.Text
    if ($newChar -match '[^\d.]') {
        # Annuler l'entrée si le caractère n'est pas un chiffre ou un point
        $eventArgs.Handled = $true
    }
}


# Attacher les événements de validation aux TextBox
$i1prix.Add_PreviewTextInput($validateInput)
$i2prix.Add_PreviewTextInput($validateInput)
$i3prix.Add_PreviewTextInput($validateInput)
$i4prix.Add_PreviewTextInput($validateInput)
$i5prix.Add_PreviewTextInput($validateInput)
$i6prix.Add_PreviewTextInput($validateInput)
$i7prix.Add_PreviewTextInput($validateInput)
$i8prix.Add_PreviewTextInput($validateInput)
$i9prix.Add_PreviewTextInput($validateInput)
$i10prix.Add_PreviewTextInput($validateInput)
$i1q.Add_PreviewTextInput($validateInput)
$i2q.Add_PreviewTextInput($validateInput)
$i3q.Add_PreviewTextInput($validateInput)
$i4q.Add_PreviewTextInput($validateInput)
$i5q.Add_PreviewTextInput($validateInput)
$i6q.Add_PreviewTextInput($validateInput)
$i7q.Add_PreviewTextInput($validateInput)
$i8q.Add_PreviewTextInput($validateInput)
$i9q.Add_PreviewTextInput($validateInput)
$i10q.Add_PreviewTextInput($validateInput)
$nbpart.Add_PreviewTextInput($validateInput)
$prixpart.Add_PreviewTextInput($validateInput)
#endregion

# Afficher la fenêtre
$mainWindow.ShowDialog()